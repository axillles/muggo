//
//  CoffeeShop.swift
//  Muggo
//
//  Created by Артем Гаврилов on 3.10.25.
//

import Foundation
import MapKit
import SwiftUI

struct CoffeeShop: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var address: String
    var latitude: Double
    var longitude: Double
    var phoneNumber: String?
    var email: String?
    var website: String?
    var rating: Double
    var reviewCount: Int
    var imageURLs: [String]
    var hours: OpeningHours
    var amenities: [Amenity]
    var menu: [MenuItem]
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), name: String, description: String, address: String, latitude: Double, longitude: Double, phoneNumber: String? = nil, email: String? = nil, website: String? = nil, rating: Double = 0.0, reviewCount: Int = 0, imageURLs: [String] = [], hours: OpeningHours = OpeningHours(), amenities: [Amenity] = [], menu: [MenuItem] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.phoneNumber = phoneNumber
        self.email = email
        self.website = website
        self.rating = rating
        self.reviewCount = reviewCount
        self.imageURLs = imageURLs
        self.hours = hours
        self.amenities = amenities
        self.menu = menu
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Computed property for MapKit coordinate
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var isOpen: Bool {
        hours.isOpenNow()
    }
    
    // Placeholder for distance calculation - would require location services in real implementation
    var distanceFromUser: Double {
        return 1.2 // Default placeholder distance in miles
    }
}

// MARK: - Opening Hours
struct OpeningHours: Codable {
    var monday: DaySchedule?
    var tuesday: DaySchedule?
    var wednesday: DaySchedule?
    var thursday: DaySchedule?
    var friday: DaySchedule?
    var saturday: DaySchedule?
    var sunday: DaySchedule?
    
    // Make it compatible with ForEach by providing array-like access
    var allDays: [(day: String, schedule: DaySchedule?)] {
        return [
            ("Monday", monday),
            ("Tuesday", tuesday),
            ("Wednesday", wednesday),
            ("Thursday", thursday),
            ("Friday", friday),
            ("Saturday", saturday),
            ("Sunday", sunday)
        ]
    }
    
    func isOpenNow() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        let currentTime = calendar.dateComponents([.hour, .minute], from: now)
        
        let daySchedule: DaySchedule?
        switch weekday {
        case 1: daySchedule = sunday
        case 2: daySchedule = monday
        case 3: daySchedule = tuesday
        case 4: daySchedule = wednesday
        case 5: daySchedule = thursday
        case 6: daySchedule = friday
        case 7: daySchedule = saturday
        default: daySchedule = nil
        }
        
        guard let schedule = daySchedule, !schedule.isClosed else { return false }
        
        let currentMinutes = (currentTime.hour ?? 0) * 60 + (currentTime.minute ?? 0)
        let openMinutes = schedule.openHour * 60 + schedule.openMinute
        let closeMinutes = schedule.closeHour * 60 + schedule.closeMinute
        
        return currentMinutes >= openMinutes && currentMinutes < closeMinutes
    }
}

struct DaySchedule: Codable {
    var openHour: Int
    var openMinute: Int
    var closeHour: Int
    var closeMinute: Int
    var isClosed: Bool
    
    init(openHour: Int = 8, openMinute: Int = 0, closeHour: Int = 18, closeMinute: Int = 0, isClosed: Bool = false) {
        self.openHour = openHour
        self.openMinute = openMinute
        self.closeHour = closeHour
        self.closeMinute = closeMinute
        self.isClosed = isClosed
    }
    
    var openTimeString: String {
        String(format: "%02d:%02d", openHour, openMinute)
    }
    
    var closeTimeString: String {
        String(format: "%02d:%02d", closeHour, closeMinute)
    }
}

// MARK: - Amenities
enum Amenity: String, CaseIterable, Codable {
    case wifi = "WiFi"
    case outdoor = "Outdoor Seating"
    case parking = "Parking"
    case delivery = "Delivery"
    case takeout = "Takeout"
    case creditCards = "Credit Cards"
    case wheelchair = "Wheelchair Accessible"
    case petFriendly = "Pet Friendly"
    case liveMusic = "Live Music"
    case studyFriendly = "Study Friendly"
    
    var icon: String {
        switch self {
        case .wifi: return "wifi"
        case .outdoor: return "chair"
        case .parking: return "car"
        case .delivery: return "bicycle"
        case .takeout: return "bag"
        case .creditCards: return "creditcard"
        case .wheelchair: return "figure.roll"
        case .petFriendly: return "pawprint"
        case .liveMusic: return "music.note"
        case .studyFriendly: return "book"
        }
    }
}

// MARK: - Sample Data
extension CoffeeShop {
    static let sampleCoffeeShops = [
        CoffeeShop(
            name: "Blue Bottle Coffee",
            description: "Premium specialty coffee roasted in small batches with meticulous attention to detail.",
            address: "1 Ferry Building, San Francisco, CA 94111",
            latitude: 37.7955,
            longitude: -122.3937,
            phoneNumber: "+1-415-896-7177",
            rating: 4.5,
            reviewCount: 1247,
            imageURLs: ["bluebottle1", "bluebottle2"],
            hours: OpeningHours(
                monday: DaySchedule(openHour: 7, openMinute: 0, closeHour: 19, closeMinute: 0),
                tuesday: DaySchedule(openHour: 7, openMinute: 0, closeHour: 19, closeMinute: 0),
                wednesday: DaySchedule(openHour: 7, openMinute: 0, closeHour: 19, closeMinute: 0),
                thursday: DaySchedule(openHour: 7, openMinute: 0, closeHour: 19, closeMinute: 0),
                friday: DaySchedule(openHour: 7, openMinute: 0, closeHour: 19, closeMinute: 0),
                saturday: DaySchedule(openHour: 8, openMinute: 0, closeHour: 20, closeMinute: 0),
                sunday: DaySchedule(openHour: 8, openMinute: 0, closeHour: 18, closeMinute: 0)
            ),
            amenities: [.wifi, .takeout, .creditCards, .wheelchair],
            menu: [
                MenuItem.sampleMenuItems[0], // Americano
                MenuItem.sampleMenuItems[1], // Cappuccino
                MenuItem.sampleMenuItems[2], // Cold Brew
                MenuItem.sampleMenuItems[3], // Croissant
                MenuItem.sampleMenuItems[4]  // Avocado Toast
            ]
        ),
        CoffeeShop(
            name: "Philz Coffee",
            description: "Custom blended coffee made one cup at a time with love.",
            address: "3101 24th St, San Francisco, CA 94110",
            latitude: 37.7526,
            longitude: -122.4141,
            phoneNumber: "+1-415-875-9370",
            rating: 4.3,
            reviewCount: 892,
            imageURLs: ["philz1", "philz2"],
            hours: OpeningHours(
                monday: DaySchedule(openHour: 6, openMinute: 30, closeHour: 18, closeMinute: 0),
                tuesday: DaySchedule(openHour: 6, openMinute: 30, closeHour: 18, closeMinute: 0),
                wednesday: DaySchedule(openHour: 6, openMinute: 30, closeHour: 18, closeMinute: 0),
                thursday: DaySchedule(openHour: 6, openMinute: 30, closeHour: 18, closeMinute: 0),
                friday: DaySchedule(openHour: 6, openMinute: 30, closeHour: 18, closeMinute: 0),
                saturday: DaySchedule(openHour: 7, openMinute: 0, closeHour: 19, closeMinute: 0),
                sunday: DaySchedule(openHour: 7, openMinute: 0, closeHour: 17, closeMinute: 0)
            ),
            amenities: [.wifi, .outdoor, .takeout, .creditCards, .studyFriendly],
            menu: [
                MenuItem.sampleMenuItems[0], // Americano
                MenuItem.sampleMenuItems[1], // Cappuccino
                MenuItem.sampleMenuItems[2], // Cold Brew
            ]
        )
    ]
}