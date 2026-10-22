//
//  RecommendationService.swift
//  Nomnom Recommender
//
//  Created by Michelle Nathania on 22/10/26.
//

import Foundation

// MARK: - Recommendation Score
struct RecommendationScores {
    let cuisine: Double
    let foodTags: Double
    let budget: Double
    let distance: Double
    let finalScore: Double
}

// MARK: - Restraurant Recommendation
// MARK: Recommended
struct RestaurantRecommendation: Identifiable {
    let restaurant: Restaurant
    let scores: RecommendationScores
    
    var id: String { restaurant.id }
}

// MARK: Excluded (not in current IA)
//struct ExcludedRestaurant: Identifiable {
//    let restaurant: Restaurant
//    let reason: String
//    
//    var id: String { restaurant.id }
//}

// MARK: Result
struct RecommendationResult {
    let recommendations: [RestaurantRecommendation]
//    let excluded: [ExcludedRestaurant]
}

// MARK: - Recommendation Service
struct RecommendationService {
    var acceptHalalClaimed = true // adjust if halal_claimed is strictly not allowed
    var conservativeUnknownInfo = true // adjust if unknown info is strictly not allowed
}

// MARK: Intersection
extension RecommendationService {
    private func overlap(
        _ first: [String],
        _ second: [String]
    ) -> Set<String> {
        Set(first).intersection(second)
    }
}

// MARK: Exclusion (not in current IA)
extension RecommendationService {
    private func exclusionReason(
        for restaurant: Restaurant,
        user: User
    ) -> String? {
        // Allergens
        let allergens = overlap(restaurant.allergensPresent ?? [], user.allergensToAvoid ?? [])
        if !allergens.isEmpty {
            return "Contains allergens: " +
            allergens.sorted().joined(separator: "")
        }
        
        // Ingredients
        let ingredients = overlap(restaurant.ingredientFlags ?? [], user.dislikedIngredients ?? [])
        if !ingredients.isEmpty {
            return "Contains disliked ingredients: " +
            ingredients.sorted().joined(separator: ", ")
        }
        
        // Tags
        let tags = overlap(restaurant.localSpecialtyTags ?? [], user.dislikedFoodTags ?? [])
        if !tags.isEmpty {
            return "Contains disliked tags: " +
            tags.sorted().joined(separator: ", ")
        }
        
        // Restrictions
        let restrictions = Set(user.dietaryRestrictions ?? [])
        let options = Set(restaurant.dietaryOptions ?? [])
        let ingredientsPresent = Set(restaurant.ingredientFlags ?? [])
        
        // Halal
        if restrictions.contains("halal_only") {
            let allowedStatuses = acceptHalalClaimed
            ? ["halal_certified", "halal_claimed"]
            : ["halal_certified"]
            
            if let status = restaurant.halalStatus, !allowedStatuses.contains(status) {
                return "Halal status '\(restaurant.halalStatus ?? "Unknown")' does not meet the user's requirement."
            }
        }
        
        // Vegetarian
        if restrictions.contains("vegetarian") {
            if !options.contains("vegerarian_options") &&
                !options.contains("vegan_options") {
                return "No vegetarian or vegan options available."
            }
            
            let meatFlags: Set<String> = [
                "pork", "lard", "beef", "chicken", "duck",
                "lamb", "offal", "fish", "shellfish"
            ]
            
            let conflicts = ingredientsPresent.intersection(meatFlags)
            
            if !conflicts.isEmpty {
                return "Contains non-vegetarian ingredient flags: " +
                conflicts.sorted().joined(separator: ", ")
            }
        }
        
        // Vegan
        if restrictions.contains("vegan") {
            if !options.contains("vegan_options") {
                return "No vegan options available."
            }
            
            let nonVeganFlags: Set<String> = [
                "pork", "lard", "beef", "chicken", "duck",
                "lamb", "offal", "fish", "shellfish",
                "dairy", "eggs", "honey"
            ]
            
            let conflicts = ingredientsPresent.intersection(nonVeganFlags)
            
            if !conflicts.isEmpty {
                return "Contains non-vegan ingredient flags: " +
                conflicts.sorted().joined(separator: ", ")
            }
        }
        
        // Pescatarian
        if restrictions.contains("pescatarian") {
            if !options.contains("pescatarian_options")
                && !options.contains("vegan_options") {
                return "No pescatarian options available."
            }
            
            let nonPescatarianFlags: Set<String> = [
                "pork", "lard", "beef", "chicken", "duck",
                "lamb", "offal"
            ]
            
            let conflicts = ingredientsPresent.intersection(nonPescatarianFlags)
            
            if !conflicts.isEmpty {
                return "Contains non-pescatarian ingredient flags: " +
                conflicts.sorted().joined(separator: ", ")
            }
        }
        
        return nil
    }
}
