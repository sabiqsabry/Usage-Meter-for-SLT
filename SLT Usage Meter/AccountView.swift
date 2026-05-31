//
//  AccountView.swift
//  SLT Usage Meter
//
//  Created by Prabhashwara on 2024-01-06.
//

import SwiftUI

struct AccountView: View {
    let serviceDetail: ServiceDetailBundle?
    let logoutAction: () -> Void
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                if let service = serviceDetail {
                    ServiceInfoCard(service: service)
                        .padding(.top)
                } else {
                    Text("Service details unavailable")
                        .foregroundColor(.secondary)
                        .padding(.top, 50)
                }
                
                Button(action: logoutAction) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Logout")
                    }
                    .foregroundColor(.white)
                    #if os(macOS)
                    .frame(maxWidth: 300)
                    #else
                    .frame(maxWidth: .infinity)
                    #endif
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                
                // About & Disclaimer Section
                VStack(spacing: 8) {
                    Text("Version \(appVersion)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("Developed by Prabhashwara")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 4) {
                        Text("This project is open source")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Link("View on GitHub", destination: URL(string: "https://github.com/prabch/Usage-Meter-for-SLT")!)
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                    }
                    .padding(.top, 4)
                    
                    Text("No personal data is collected or stored externally; login credentials are used only to obtain a secure token, which is stored securely in your device's Keychain.")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.top, 12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}
