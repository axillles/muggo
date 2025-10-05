//
//  User.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import Foundation
import SwiftUI

struct User: Codable, Identifiable {
    let id: UUID
    var email: String
    var name: String
    var phoneNumber: String?
    var profileImageURL: String?
    var createdAt: Date
    var isEmailVerified: Bool
    
    init(id: UUID = UUID(), email: String, name: String, phoneNumber: String? = nil, profileImageURL: String? = nil, createdAt: Date = Date(), isEmailVerified: Bool = false) {
        self.id = id
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        self.createdAt = createdAt
        self.isEmailVerified = isEmailVerified
    }
}

// MARK: - Sample Data
extension User {
    static let sampleUser = User(
        email: "john.doe@example.com",
        name: "John Doe",
        phoneNumber: "+1-555-123-4567",
        isEmailVerified: true
    )
}