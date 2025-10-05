//
//  MenuItem.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import Foundation
import SwiftUI

struct MenuItem: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var price: Double
    var category: MenuCategory
    var imageURL: String?
    var isAvailable: Bool
    var customizations: [Customization]
    var nutritionalInfo: NutritionalInfo?
    var tags: [String]
    var estimatedPrepTime: Int // in minutes
    
    init(id: UUID = UUID(), name: String, description: String, price: Double, category: MenuCategory, imageURL: String? = nil, isAvailable: Bool = true, customizations: [Customization] = [], nutritionalInfo: NutritionalInfo? = nil, tags: [String] = [], estimatedPrepTime: Int = 5) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.category = category
        self.imageURL = imageURL
        self.isAvailable = isAvailable
        self.customizations = customizations
        self.nutritionalInfo = nutritionalInfo
        self.tags = tags
        self.estimatedPrepTime = estimatedPrepTime
    }
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
}

// MARK: - Menu Category
enum MenuCategory: String, CaseIterable, Codable {
    case coffee = "Coffee"
    case espresso = "Espresso"
    case tea = "Tea"
    case coldBrew = "Cold Brew"
    case frappuccino = "Frappuccino"
    case pastries = "Pastries"
    case sandwiches = "Sandwiches"
    case salads = "Salads"
    case snacks = "Snacks"
    case desserts = "Desserts"
    case beverages = "Other Beverages"
    
    var icon: String {
        switch self {
        case .coffee: return "cup.and.saucer"
        case .espresso: return "cup.and.saucer.fill"
        case .tea: return "leaf"
        case .coldBrew: return "snow"
        case .frappuccino: return "snow"
        case .pastries: return "birthday.cake"
        case .sandwiches: return "fork.knife"
        case .salads: return "leaf.circle"
        case .snacks: return "bag.fill"
        case .desserts: return "birthday.cake.fill"
        case .beverages: return "wineglass"
        }
    }
}

// MARK: - Customization
struct Customization: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var options: [CustomizationOption]
    var isRequired: Bool
    var maxSelections: Int // 1 for single selection, > 1 for multiple
    
    init(id: UUID = UUID(), name: String, options: [CustomizationOption], isRequired: Bool = false, maxSelections: Int = 1) {
        self.id = id
        self.name = name
        self.options = options
        self.isRequired = isRequired
        self.maxSelections = maxSelections
    }
}

struct CustomizationOption: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var priceModifier: Double // additional cost or discount
    var isDefault: Bool
    
    init(id: UUID = UUID(), name: String, priceModifier: Double = 0.0, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.priceModifier = priceModifier
        self.isDefault = isDefault
    }
    
    var formattedPriceModifier: String {
        if priceModifier == 0 {
            return ""
        } else if priceModifier > 0 {
            return "+$\(String(format: "%.2f", priceModifier))"
        } else {
            return "-$\(String(format: "%.2f", abs(priceModifier)))"
        }
    }
}

// MARK: - Nutritional Info
struct NutritionalInfo: Codable, Hashable, Equatable {
    var calories: Int?
    var fat: Double? // grams
    var saturatedFat: Double? // grams
    var sodium: Double? // mg
    var carbohydrates: Double? // grams
    var fiber: Double? // grams
    var sugar: Double? // grams
    var protein: Double? // grams
    var caffeine: Double? // mg
}

// MARK: - Sample Data
extension MenuItem {
    static let sampleMenuItems = [
        // Coffee
        MenuItem(
            name: "Americano",
            description: "Rich espresso shots with hot water",
            price: 3.25,
            category: .espresso,
            customizations: [
                Customization(
                    name: "Size",
                    options: [
                        CustomizationOption(name: "Small", priceModifier: -0.50),
                        CustomizationOption(name: "Medium", isDefault: true),
                        CustomizationOption(name: "Large", priceModifier: 0.50)
                    ],
                    isRequired: true
                ),
                Customization(
                    name: "Extra Shots",
                    options: [
                        CustomizationOption(name: "1 Extra Shot", priceModifier: 0.75),
                        CustomizationOption(name: "2 Extra Shots", priceModifier: 1.50)
                    ],
                    maxSelections: 1
                )
            ],
            tags: ["Hot", "Strong", "Classic"],
            estimatedPrepTime: 3
        ),
        MenuItem(
            name: "Cappuccino",
            description: "Espresso with steamed milk and foam",
            price: 4.25,
            category: .espresso,
            customizations: [
                Customization(
                    name: "Size",
                    options: [
                        CustomizationOption(name: "Small", priceModifier: -0.50),
                        CustomizationOption(name: "Medium", isDefault: true),
                        CustomizationOption(name: "Large", priceModifier: 0.50)
                    ],
                    isRequired: true
                ),
                Customization(
                    name: "Milk Type",
                    options: [
                        CustomizationOption(name: "Whole Milk", isDefault: true),
                        CustomizationOption(name: "2% Milk"),
                        CustomizationOption(name: "Oat Milk", priceModifier: 0.65),
                        CustomizationOption(name: "Almond Milk", priceModifier: 0.65),
                        CustomizationOption(name: "Soy Milk", priceModifier: 0.65)
                    ],
                    isRequired: true
                )
            ],
            nutritionalInfo: NutritionalInfo(calories: 120, fat: 6.0, carbohydrates: 12.0, protein: 8.0, caffeine: 150),
            tags: ["Hot", "Creamy", "Classic"],
            estimatedPrepTime: 4
        ),
        MenuItem(
            name: "Cold Brew",
            description: "Smooth, rich coffee steeped for 12 hours",
            price: 3.75,
            category: .coldBrew,
            customizations: [
                Customization(
                    name: "Size",
                    options: [
                        CustomizationOption(name: "Medium", isDefault: true),
                        CustomizationOption(name: "Large", priceModifier: 0.50)
                    ],
                    isRequired: true
                ),
                Customization(
                    name: "Add-ins",
                    options: [
                        CustomizationOption(name: "Vanilla Syrup", priceModifier: 0.50),
                        CustomizationOption(name: "Caramel Syrup", priceModifier: 0.50),
                        CustomizationOption(name: "Simple Syrup", priceModifier: 0.50),
                        CustomizationOption(name: "Cream", priceModifier: 0.25)
                    ],
                    maxSelections: 3
                )
            ],
            tags: ["Cold", "Smooth", "Less Acidic"],
            estimatedPrepTime: 2
        ),
        // Pastries
        MenuItem(
            name: "Croissant",
            description: "Buttery, flaky French pastry",
            price: 2.95,
            category: .pastries,
            customizations: [
                Customization(
                    name: "Warming",
                    options: [
                        CustomizationOption(name: "Room Temperature", isDefault: true),
                        CustomizationOption(name: "Warmed")
                    ],
                    isRequired: true
                )
            ],
            nutritionalInfo: NutritionalInfo(calories: 231, fat: 12.0, carbohydrates: 26.0, protein: 5.0),
            tags: ["French", "Buttery", "Flaky"],
            estimatedPrepTime: 1
        ),
        MenuItem(
            name: "Avocado Toast",
            description: "Fresh avocado on multigrain bread with sea salt",
            price: 8.50,
            category: .sandwiches,
            customizations: [
                Customization(
                    name: "Toppings",
                    options: [
                        CustomizationOption(name: "Everything Bagel Seasoning", priceModifier: 0.25),
                        CustomizationOption(name: "Red Pepper Flakes"),
                        CustomizationOption(name: "Lime Squeeze"),
                        CustomizationOption(name: "Cherry Tomatoes", priceModifier: 0.50)
                    ],
                    maxSelections: 4
                )
            ],
            nutritionalInfo: NutritionalInfo(calories: 320, fat: 18.0, carbohydrates: 35.0, fiber: 12.0, protein: 8.0),
            tags: ["Healthy", "Vegetarian", "Fresh"],
            estimatedPrepTime: 3
        )
    ]
    
    static let sampleCoffeeMenuItems = sampleMenuItems.filter { $0.category == .coffee || $0.category == .espresso || $0.category == .coldBrew }
    static let sampleFoodMenuItems = sampleMenuItems.filter { $0.category == .pastries || $0.category == .sandwiches || $0.category == .salads }
}