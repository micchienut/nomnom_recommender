//
//  User.swift
//  Nomnom Recommender
//
//  Created by Michelle Nathania on 22/10/26.
//

import Foundation

// MARK: - User Struct
struct User: Identifiable {
    // User information
    let userID: String
    var username: String
    var name: String
    
    // Restriction
    var dietaryRestrictions: [String]?
    var allergensToAvoid: [String]?
    
    // Preferences
    var dislikedIngredients: [String]?
    var dislikedFoodTags: [String]?
    var preferredCuisine: [String]?
    var preferredFoodTags: [String]?
    var spiceTolerance: String?
    
    var budgetMinIDR: Double?
    var budgetMaxIDR: Double?
    
    var id: String { userID }
}
