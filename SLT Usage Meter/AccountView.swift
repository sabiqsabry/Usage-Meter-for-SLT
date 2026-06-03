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
    
    @State private var showingLogoutConfirmation = false
    
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
                
                Button(action: {
                    showingLogoutConfirmation = true
                }) {
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
                .confirmationDialog("Are you sure you want to log out?", isPresented: $showingLogoutConfirmation, titleVisibility: .visible) {
                    Button("Log Out", role: .destructive) {
                        logoutAction()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("You will be logged out of all devices on your Apple ID.")
                }
                
                // About & Disclaimer Section
                VStack(spacing: 12) {
                    Text("Usage Meter for SLT is an independent app and is not affiliated with or endorsed by SLT Mobitel")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("•••")
                        .font(.footnote)
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Link(destination: URL(string: "https://prabch.com")!) {
                        HStack(spacing: 6) {
                            Image("favicon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .cornerRadius(4)
                            
                            Text("prabch.com")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Text("This project is open source; you can view and audit the code on [GitHub](https://github.com/prabch/Usage-Meter-for-SLT).")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("No personal data is collected or stored externally; login credentials are used only to obtain a secure token, which is stored securely in your device's Keychain.")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.top, 4)
                    
                    Text("Version \(appVersion)")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}
