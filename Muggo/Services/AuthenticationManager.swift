//
//  AuthenticationManager.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import Foundation
import SwiftUI
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let currentUserKey = "CurrentUser"
    private let isLoggedInKey = "IsLoggedIn"
    
    init() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Status
    private func checkAuthenticationStatus() {
        isAuthenticated = userDefaults.bool(forKey: isLoggedInKey)
        if isAuthenticated {
            loadCurrentUser()
        }
    }
    
    // MARK: - Registration
    func register(email: String, password: String, name: String, phoneNumber: String? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            // Validate input
            if !isValidEmail(email) {
                errorMessage = "Please enter a valid email address"
                isLoading = false
                return
            }
            
            if password.count < 6 {
                errorMessage = "Password must be at least 6 characters long"
                isLoading = false
                return
            }
            
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errorMessage = "Please enter your name"
                isLoading = false
                return
            }
            
            // Check if user already exists (in real app, this would be server-side)
            if userExists(email: email) {
                errorMessage = "An account with this email already exists"
                isLoading = false
                return
            }
            
            // Create new user
            let newUser = User(
                email: email,
                name: name,
                phoneNumber: phoneNumber
            )
            
            // Save user and authenticate
            currentUser = newUser
            isAuthenticated = true
            
            saveCurrentUser()
            userDefaults.set(true, forKey: isLoggedInKey)
            
            isLoading = false
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            // Validate input
            if !isValidEmail(email) {
                errorMessage = "Please enter a valid email address"
                isLoading = false
                return
            }
            
            if password.isEmpty {
                errorMessage = "Please enter your password"
                isLoading = false
                return
            }
            
            // In a real app, this would validate against server
            // For now, we'll simulate a successful login with sample user
            if email.lowercased() == "demo@muggo.com" && password == "demo123" {
                currentUser = User.sampleUser
                isAuthenticated = true
                
                saveCurrentUser()
                userDefaults.set(true, forKey: isLoggedInKey)
                
                isLoading = false
            } else {
                errorMessage = "Invalid email or password"
                isLoading = false
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
        
        userDefaults.removeObject(forKey: currentUserKey)
        userDefaults.set(false, forKey: isLoggedInKey)
    }
    
    // MARK: - Update Profile
    func updateProfile(name: String, phoneNumber: String?) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            guard var user = currentUser else {
                errorMessage = "No user logged in"
                isLoading = false
                return
            }
            
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errorMessage = "Please enter your name"
                isLoading = false
                return
            }
            
            user.name = name
            user.phoneNumber = phoneNumber
            
            currentUser = user
            saveCurrentUser()
            
            isLoading = false
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(email: String) async -> Bool {
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In real app, this would send reset email via server
        return isValidEmail(email)
    }
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func userExists(email: String) -> Bool {
        // In real app, this would check against server database
        // For demo purposes, let's say these emails are taken
        let existingEmails = ["test@example.com", "admin@muggo.com"]
        return existingEmails.contains(email.lowercased())
    }
    
    private func saveCurrentUser() {
        guard let user = currentUser,
              let encoded = try? JSONEncoder().encode(user) else { return }
        userDefaults.set(encoded, forKey: currentUserKey)
    }
    
    private func loadCurrentUser() {
        guard let data = userDefaults.data(forKey: currentUserKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else { return }
        currentUser = user
    }
    
    // MARK: - Demo Methods
    func loginAsDemo() {
        currentUser = User.sampleUser
        isAuthenticated = true
        saveCurrentUser()
        userDefaults.set(true, forKey: isLoggedInKey)
    }
}

// MARK: - Authentication Validation
extension AuthenticationManager {
    enum ValidationError: LocalizedError {
        case invalidEmail
        case passwordTooShort
        case nameEmpty
        case userExists
        case invalidCredentials
        
        var errorDescription: String? {
            switch self {
            case .invalidEmail:
                return "Please enter a valid email address"
            case .passwordTooShort:
                return "Password must be at least 6 characters long"
            case .nameEmpty:
                return "Please enter your name"
            case .userExists:
                return "An account with this email already exists"
            case .invalidCredentials:
                return "Invalid email or password"
            }
        }
    }
}