//
//  LoginView.swift
//  SLT Usage Meter
//
//  Created by Prabhashwara on 2024-06-30.
//

import SwiftUI
import WidgetKit


// Custom URLSession logic moved to NetworkManager

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var accessToken: String = ""
    @State private var refreshToken: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var isPasswordVisible: Bool = false
    
    let loginAction: (String) -> Void
    
    // Adaptive background color for light/dark mode
    private var cardBackgroundColor: Color {
        #if os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color(UIColor.systemBackground)
        #endif
    }

    private var instructionText: Text {
        Text("Use the same email and password you use for the ")
            .font(.caption)
            .foregroundColor(.primary.opacity(0.7))
        + Text("[myslt.slt.lk](https://myslt.slt.lk)")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.blue)
        + Text(" portal")
            .font(.caption)
            .foregroundColor(.primary.opacity(0.7))
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 60)
                        
                        // Logo/Title Section
                        VStack(spacing: 12) {
                            Image(systemName: "speedometer")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .padding(.bottom, 8)
                            
                            Text("Usage Meter for SLT")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Monitor your SLT broadband usage")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.bottom, 40)
                        
                        // Login Card
                        VStack(spacing: 24) {
                            // Instructions
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("Login with your MySLT credentials")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                }
                                
                                instructionText
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                    .disableAutocorrection(true)
                                    #if os(iOS)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    #endif
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    if isPasswordVisible {
                                        TextField("Enter your password", text: $password)
                                            .textFieldStyle(.plain)
                                            .disableAutocorrection(true)
                                            #if os(iOS)
                                            .autocapitalization(.none)
                                            #endif
                                            .onSubmit {
                                                if !email.isEmpty && !password.isEmpty {
                                                    login()
                                                }
                                            }
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                            .textFieldStyle(.plain)
                                            .onSubmit {
                                                if !email.isEmpty && !password.isEmpty {
                                                    login()
                                                }
                                            }
                                    }
                                    
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                            .foregroundColor(.secondary)
                                            .font(.body)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            // Error Message
                            if !errorMessage.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Login Button
                            Button(action: {
                                login()
                            }) {
                                Text("Login")
                                    .fontWeight(.semibold)
                                    .opacity(isLoading ? 0 : 1)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .overlay {
                                        if isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                            .disabled(isLoading || email.isEmpty || password.isEmpty)
                            .opacity((isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                        }
                        .padding(24)
                        .background(cardBackgroundColor)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
                
                // Disclaimer at very bottom
                VStack(spacing: 4) {
                    Text("Usage Meter for SLT is an independent app and is not affiliated with or endorsed by SLT Mobitel.")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Text("No personal data is collected or stored externally")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
    }

    private func login() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let token = try await NetworkManager.shared.login(username: email, password: password)
                
                print("LoginView: Login success")
                DispatchQueue.main.async {
                    self.accessToken = token
                    self.isLoading = false
                    self.loginAction(token)
                }
            } catch {
                print("LoginView: Login error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Map generic errors to user friendly messages if needed
                    if let nsError = error as NSError? {
                         if nsError.domain == "Auth" && (nsError.code == 401 || nsError.code == 403) {
                             self.errorMessage = "Invalid credentials. Please check your email and password."
                         } else {
                             self.errorMessage = error.localizedDescription
                         }
                    } else {
                         self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

// LoginResponse and local models logic moved to Shared/Models.swift

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loginAction: { _ in })
    }
}

