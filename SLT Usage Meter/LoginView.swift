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
    @Environment(\.colorScheme) var colorScheme
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var accessToken: String = ""
    @State private var refreshToken: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var isPasswordVisible: Bool = false
    
    enum PasswordFieldType: Hashable {
        case secure, plain
    }
    @FocusState private var focusedPasswordField: PasswordFieldType?
    
    let loginAction: (String) -> Void
    
    // Adaptive background color for light/dark mode
    private var cardBackgroundColor: Color {
        #if os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color(UIColor.systemBackground)
        #endif
    }

    private var instructionText: some View {
        Text("Use the same email and password you use for the **[myslt.slt.lk](https://myslt.slt.lk)** portal")
            .font(.caption)
            .foregroundColor(.primary.opacity(0.7))
            .tint(.blue)
            .fixedSize(horizontal: false, vertical: true)
    }

    var body: some View {
        ZStack {
            // Background gradient
            ZStack {
                if colorScheme == .dark {
                    Color.black.ignoresSafeArea()
                }
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark ? [Color.blue.opacity(0.4), Color.cyan.opacity(0.4)] : [.blue, .cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 10)
                            .frame(maxHeight: 60)
                        
                        // Logo/Title Section
                        VStack(spacing: 12) {
                            Image(systemName: "speedometer")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .padding(.bottom, 8)
                            
                            Text("Usage Meter for SLT")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Peep your SLT broadband usage directly from your home screen")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 32)
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
                                    ZStack(alignment: .leading) {
                                        TextField("Enter your password", text: $password)
                                            .textFieldStyle(.plain)
                                            .disableAutocorrection(true)
                                            #if os(iOS)
                                            .autocapitalization(.none)
                                            #endif
                                            .focused($focusedPasswordField, equals: .plain)
                                            .frame(minHeight: 24)
                                            .opacity(isPasswordVisible ? 1 : 0)
                                            .allowsHitTesting(isPasswordVisible)
                                            .onSubmit {
                                                if !email.isEmpty && !password.isEmpty { login() }
                                            }
                                            
                                        SecureField("Enter your password", text: $password)
                                            .textFieldStyle(.plain)
                                            .focused($focusedPasswordField, equals: .secure)
                                            .frame(minHeight: 24)
                                            .opacity(isPasswordVisible ? 0 : 1)
                                            .allowsHitTesting(!isPasswordVisible)
                                            .onSubmit {
                                                if !email.isEmpty && !password.isEmpty { login() }
                                            }
                                    }
                                    
                                    Button(action: {
                                        let wasFocused = (focusedPasswordField != nil)
                                        isPasswordVisible.toggle()
                                        if wasFocused {
                                            focusedPasswordField = isPasswordVisible ? .plain : .secure
                                        }
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
                        .padding(.bottom, 20)
                        
                        Spacer(minLength: 0)
                        
                        // Disclaimer at very bottom
                        VStack(spacing: 4) {
                            Text("Usage Meter for SLT is an independent app and is not affiliated with or endorsed by SLT Mobitel.")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 32)
                            Text("No personal data is collected or stored externally")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 32)
                        }
                        .padding(.bottom, 20)
                    }
                    .frame(maxWidth: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        #if canImport(UIKit)
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        #endif
                        focusedPasswordField = nil
                    }
                }
                .adaptiveScrollBounce()
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

extension View {
    @ViewBuilder
    func adaptiveScrollBounce() -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            self.scrollBounceBehavior(.basedOnSize)
        } else {
            self
        }
    }
}
