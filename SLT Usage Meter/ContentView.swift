//
//  ContentView.swift
//  SLT Usage Meter
//
//  Created by Prabhashwara on 2024-06-30.
//

import SwiftUI
import WidgetKit


struct ContentView: View {
    @State private var isLoggedIn: Bool = false
    @State private var accessToken: String?

    var body: some View {
        Group {
            if isLoggedIn {
                MainView(accessToken: accessToken ?? "", logoutAction: logout)
            } else {
                LoginView(loginAction: { token in
                    print("ContentView: Login successful. Received token: \(token)")
                    self.accessToken = token
                    self.isLoggedIn = true

                    // Store accessToken securely (e.g., UserDefaults (shared suite) or Keychain)
                    if let defaults = UserDefaults(suiteName: "group.com.prabch.sltusage") {
                        defaults.set(token, forKey: "accessToken")
                        print("ContentView: Access token stored in shared UserDefaults.")
                    } else {
                        print("ContentView: Failed to load shared UserDefaults suite.")
                    }
                    
                    // Reload widget timelines
                    WidgetCenter.shared.reloadAllTimelines()
                })
            }
        }
        .onAppear {
            // Check for stored credentials on app launch
            checkStoredCredentials()
            
            // Listen for token expiration notifications
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("TokenExpired"),
                object: nil,
                queue: .main
            ) { _ in
                print("ContentView: Token expired notification received. Logging out...")
                logout()
            }
        }
    }
    
    private func checkStoredCredentials() {
        print("ContentView: Checking for stored credentials...")
        
        guard let defaults = UserDefaults(suiteName: "group.com.prabch.sltusage") else {
            print("ContentView: Failed to load shared UserDefaults suite.")
            return
        }
        
        // Check if we have a stored access token and username
        if let storedAccessToken = defaults.string(forKey: "accessToken"),
           let storedUsername = defaults.string(forKey: "username") {
            print("ContentView: Found stored credentials for user: \(storedUsername)")
            self.accessToken = storedAccessToken
            self.isLoggedIn = true
        } else {
            print("ContentView: No stored credentials found. Showing login screen.")
            self.isLoggedIn = false
        }
    }

    private func logout() {
        print("ContentView: Logout triggered.")
        if let defaults = UserDefaults(suiteName: "group.com.prabch.sltusage") {
            defaults.removeObject(forKey: "accessToken")
            defaults.removeObject(forKey: "refreshToken")
            defaults.removeObject(forKey: "username")
            print("ContentView: Tokens and username removed from shared UserDefaults.")
        }
        self.accessToken = nil
        self.isLoggedIn = false
        print("ContentView: isLoggedIn set to false.")
        
        // Reload widget timelines
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




