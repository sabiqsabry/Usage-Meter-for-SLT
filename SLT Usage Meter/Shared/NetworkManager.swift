//
//  NetworkManager.swift
//  SLT Usage Meter
//
//  Created by Prabhashwara on 2026-01-06.
//

import Foundation
import WidgetKit

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // Custom URLSession with extended timeouts to prevent -1005 errors
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60  // 60 seconds
        configuration.timeoutIntervalForResource = 120 // 120 seconds
        configuration.waitsForConnectivity = false
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }()
    
    // MARK: - Auth Helpers
    
    var accessToken: String? {
        get { UserDefaults(suiteName: AppConstants.suiteName)?.string(forKey: AppConstants.Keys.accessToken) }
    }
    
    var username: String? {
        get { UserDefaults(suiteName: AppConstants.suiteName)?.string(forKey: AppConstants.Keys.username) }
    }
    
    func logout() {
        if let defaults = UserDefaults(suiteName: AppConstants.suiteName) {
            defaults.removeObject(forKey: AppConstants.Keys.accessToken)
            defaults.removeObject(forKey: AppConstants.Keys.refreshToken)
            defaults.removeObject(forKey: AppConstants.Keys.username)
        }
        // Notification for App to show login screen
        NotificationCenter.default.post(name: NSNotification.Name("TokenExpired"), object: nil)
        
        // Reload widgets to show logged out state
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - API Calls
    
    func login(username: String, password: String) async throws -> String {
        let url = APIEndpoint.login.url
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConstants.API.clientId, forHTTPHeaderField: "X-Ibm-Client-Id")
        
        let body = "username=\(username)&password=\(password)&channelID=WEB"
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 200 {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            // Save credentials
            if let defaults = UserDefaults(suiteName: AppConstants.suiteName) {
                defaults.set(loginResponse.accessToken, forKey: AppConstants.Keys.accessToken)
                defaults.set(loginResponse.refreshToken, forKey: AppConstants.Keys.refreshToken)
                defaults.set(username, forKey: AppConstants.Keys.username)
                WidgetCenter.shared.reloadAllTimelines()
            }
            
            return loginResponse.accessToken
        } else {
            throw NSError(domain: "Auth", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Login failed with status \(httpResponse.statusCode)"])
        }
    }
    
    func fetchAccounts() async throws -> [AccountInfo] {
        guard let username = username else { throw URLError(.userAuthenticationRequired) }
        
        let url = APIEndpoint.accountDetail(username: username).url
        let finalRequest = try createRequest(url: url)
        
        let (data, _) = try await execute(request: finalRequest)
        let response = try JSONDecoder().decode(AccountResponse.self, from: data)
        return response.dataBundle ?? []
    }
    
    func fetchServiceDetails(telephoneNo: String) async throws -> ServiceDetailBundle? {
        let url = URL(string: "\(AppConstants.API.baseURL)/AccountOMNI/GetServiceDetailRequest?categoryID=BB&telephoneNo=\(telephoneNo)")!
        let request = try createRequest(url: url)
        
        let (data, _) = try await execute(request: request)
        let response = try JSONDecoder().decode(ServiceDetailResponse.self, from: data)
        return response.dataBundle
    }
    
    func fetchUsageSummary(subscriberID: String) async throws -> UsageSummaryBundle? {
        let internationalNumber = convertToInternationalFormat(subscriberID)
        let url = APIEndpoint.usageSummary(subscriberID: internationalNumber).url
        let request = try createRequest(url: url)
        
        let (data, _) = try await execute(request: request)
        let response = try JSONDecoder().decode(UsageSummaryResponse.self, from: data)
        return response.dataBundle
    }
    
    func fetchVASBundles(subscriberID: String) async throws -> [UsageDetail] {
        let internationalNumber = convertToInternationalFormat(subscriberID)
        let url = APIEndpoint.vasBundles(subscriberID: internationalNumber).url
        let request = try createRequest(url: url)
        
        let (data, _) = try await execute(request: request)
        let response = try JSONDecoder().decode(UsageDataResponse.self, from: data)
        return response.dataBundle?.usageDetails ?? []
    }
    
    // MARK: - Private Helpers
    
    // Helper function to convert phone number to international format
    // Making it static/internal so it can be used if needed, or just private here if only used for API calls
    private func convertToInternationalFormat(_ phoneNumber: String) -> String {
        let cleaned = phoneNumber.replacingOccurrences(of: " ", with: "")
                                 .replacingOccurrences(of: "-", with: "")
        if cleaned.hasPrefix("0") {
            return "94" + cleaned.dropFirst()
        }
        if cleaned.hasPrefix("94") {
            return cleaned
        }
        return "94" + cleaned
    }
    
    private func createRequest(url: URL) throws -> URLRequest {
        guard let token = accessToken else {
            throw URLError(.userAuthenticationRequired)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("bearer \(token)", forHTTPHeaderField: "authorization")
        request.setValue(AppConstants.API.clientId, forHTTPHeaderField: "x-ibm-client-id")
        return request
    }
    
    private func execute(request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                // Token expired
                logout()
                throw URLError(.userAuthenticationRequired)
            }
        }
        
        return (data, response)
    }
}
