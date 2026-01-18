//
//  Constants.swift
//  SLT Usage Meter
//
//  Created by Prabhashwara on 2026-01-06.
//

import Foundation

struct AppConstants {
    static let suiteName = "group.com.prabch.sltusage"
    
    struct API {
        static let baseURL = "https://omniscapp.slt.lk/slt/ext/api"
        static let clientId = Secrets.clientId
    }
    
    struct Keys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let username = "username" // This is the email
    }
}

enum APIEndpoint {
    case login
    case accountDetail(username: String)
    case usageSummary(subscriberID: String)
    case vasBundles(subscriberID: String)
    
    var url: URL {
        switch self {
        case .login:
            return URL(string: "\(AppConstants.API.baseURL)/Account/Login")!
        case .accountDetail(let username):
            return URL(string: "\(AppConstants.API.baseURL)/AccountOMNI/GetAccountDetailRequest?username=\(username)")!
        case .usageSummary(let subscriberID):
            return URL(string: "\(AppConstants.API.baseURL)/BBVAS/UsageSummary?subscriberID=\(subscriberID)")!
        case .vasBundles(let subscriberID):
            return URL(string: "\(AppConstants.API.baseURL)/BBVAS/GetDashboardVASBundles?subscriberID=\(subscriberID)")!
        }
    }
}
