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
                
                
                // Disclaimer and About
                VStack(spacing: 12) {
                    Text("Usage Meter for SLT is an independent app and is not affiliated with or endorsed by SLT Mobitel.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("The app helps SLT users monitor their data usage using SLT’s publicly available APIs.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("No personal data is collected or stored externally; login credentials are used only to obtain a secure token, which is stored locally on your device.")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Developed by Prabhashwara")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.8))
                        .padding(.top, 8)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}
