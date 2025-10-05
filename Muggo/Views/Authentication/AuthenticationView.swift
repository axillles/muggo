//
//  AuthenticationView.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var showingRegistration = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.brown.opacity(0.8), Color.brown.opacity(0.4)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo and Title
                    VStack(spacing: 20) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("Muggo")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Find & Order Your Perfect Coffee")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Authentication Options
                    VStack(spacing: 20) {
                        // Login Button
                        NavigationLink(destination: LoginView()) {
                            HStack {
                                Spacer()
                                Text("Sign In")
                                    .font(.headline)
                                    .foregroundColor(.brown)
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Register Button
                        NavigationLink(destination: RegisterView()) {
                            HStack {
                                Spacer()
                                Text("Create Account")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        }
                        
                        // Demo Login
                        DemoLoginButton()
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct DemoLoginButton: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Button(action: {
            authManager.loginAsDemo()
        }) {
            HStack {
                Image(systemName: "person.circle.fill")
                Text("Continue as Demo User")
                    .font(.subheadline)
            }
            .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 20)
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationManager())
}