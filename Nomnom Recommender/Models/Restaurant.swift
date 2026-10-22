//
//  Restaurant.swift
//  Nomnom Recommender
//
//  Created by Michelle Nathania on 21/10/26.
//

import Foundation

// MARK: Restaurant Struct
struct Restaurant: Decodable, Identifiable {
    // Restaurant information
    let restaurantID: String
    let restaurantName: String
    let address: String
    let openingHours: String?
    var isBookmarked: Bool = false
    
    // Location
    let latitude: Double
    let longitude: Double
    
    // Budget
    let priceMinIDR: Double
    let priceMaxIDR: Double
    
    // Preferences
    let cuisine: [String]?
    let localSpecialtyTags: [String]?
    
    // Restrictions
    let dietaryOptions: [String]?
    let ingredientFlags: [String]?
    let allergensPresent: [String]?
    let halalStatus: String?
    
    var id: String { restaurantID }
    
    enum CodingKeys: String, CodingKey {
        case restaurantID = "restaurant_id"
        case restaurantName = "restaurant_name"
        case address
        case openingHours = "opening_hours"
        case latitude
        case longitude
        case priceMinIDR = "price_min_idr"
        case priceMaxIDR = "price_max_idr"
        case cuisine
        case localSpecialtyTags = "local_specialty_tags"
        case dietaryOptions = "dietary_options"
        case ingredientFlags = "ingredient_flags"
        case allergensPresent = "allergens_present"
        case halalStatus = "halal_status"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        restaurantID = try container.decode(String.self, forKey: .restaurantID)
        restaurantName = try container.decode(String.self, forKey: .restaurantName)
        address = try container.decode(String.self, forKey: .address)
        openingHours = try container.decodeIfPresent(String.self, forKey: .openingHours) ?? "unknown"
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        priceMinIDR = try container.decode(Double.self, forKey: .priceMinIDR)
        priceMaxIDR = try container.decode(Double.self, forKey: .priceMaxIDR)
        cuisine = try container.decodeIfPresent([String].self, forKey: .cuisine) ?? []
        localSpecialtyTags = try container.decodeIfPresent([String].self, forKey: .localSpecialtyTags) ?? []
        dietaryOptions = try container.decodeIfPresent([String].self, forKey: .dietaryOptions) ?? []
        ingredientFlags = try container.decodeIfPresent([String].self, forKey: .ingredientFlags) ?? []
        allergensPresent = try container.decodeIfPresent([String].self, forKey: .allergensPresent) ?? []
        halalStatus = try container.decodeIfPresent(String.self, forKey: .halalStatus) ?? "unknown"
    }
}
