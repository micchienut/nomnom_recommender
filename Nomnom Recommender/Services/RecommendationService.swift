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
//    let distance: Double
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
struct ExcludedRestaurant: Identifiable {
    let restaurant: Restaurant
    let reason: String
    
    var id: String { restaurant.id }
}

// MARK: Recommendation Result
struct RecommendationResult {
    let recommendations: [RestaurantRecommendation]
    let excluded: [ExcludedRestaurant]
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
            allergens.sorted().joined(separator: ", ")
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
            if !options.contains("vegetarian_options") &&
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

// MARK: Clamp Function
extension RecommendationService {
    private func clamp(
        _ value: Double,
        min lower: Double = 0,
        max upper: Double = 1
    ) -> Double {
        min(max(value, lower), upper)
    }
}

// MARK: Cuisine Score
extension RecommendationService {
    private func cuisineScore(
        _ restaurant: Restaurant,
        _ user: User
    ) -> Double {
        guard !(user.preferredCuisine?.isEmpty ?? true) else {
            return 0.5 // might still need to adjust the score if the user doesn't put anything on the input field
        }
        
        return Double(
            overlap(user.preferredCuisine ?? [], restaurant.cuisine ?? []).count
        ) / Double(user.preferredCuisine?.count ?? 1)
    }
}

// MARK: Food Tag Score
extension RecommendationService {
    private func foodTagScore(
        _ restaurant: Restaurant,
        _ user: User
    ) -> Double {
        guard !(user.preferredFoodTags?.isEmpty ?? true) else {
            return 0.5
        }
        
        return Double(
            overlap(user.preferredFoodTags ?? [], restaurant.localSpecialtyTags ?? []).count
        ) / Double(user.preferredFoodTags?.count ?? 1)
    }
}

// MARK: Budget Score
extension RecommendationService {
    private func budgetScore(
        _ restaurant: Restaurant,
        _ user: User
    ) -> Double {
        let restaurantMin = restaurant.priceMinIDR
        let restaurantMax = restaurant.priceMaxIDR
        let userMin = user.budgetMinIDR
        let userMax = user.budgetMaxIDR
        
        if restaurantMin <= userMax && restaurantMax >= userMin {
            // Perfect match
            if restaurantMin >= userMin && restaurantMax <= userMax {
                return 1.0
            }
            // Partial match
            // TODO: Adjust as needed
            return 0.7
        }
        
        // Too expensive
        if restaurantMin > userMax {
            return clamp(
                1-(restaurantMin-userMax) / max(userMax, 1)
            )
        }
        
        // Too cheap
        return clamp(
            1-(userMin-restaurantMax) / max(userMin, 1)
        )
    }
}

// MARK: Distance Score
// TODO: Add distance score metrics, need MapKit
//extension RecommendationService {
//    private func distanceScore(
//        _ restaurant: Restaurant,
//        _ user: User
//    ) -> Double {
//    }
//}

// MARK: Calculate Score
extension RecommendationService {
    private func calculateScore(
        _ restaurant: Restaurant,
        _ user: User
    ) -> RecommendationScores {
        let cuisine = cuisineScore(restaurant, user)
        let foodTags = foodTagScore(restaurant, user)
        let budget = budgetScore(restaurant, user)
        
        let finalScore = (cuisine + foodTags + budget) / 3.0
        
        return RecommendationScores(cuisine: cuisine, foodTags: foodTags, budget: budget, finalScore: finalScore)
    }
}

// MARK: Output
extension RecommendationService {
    func recommend(
        restaurants: [Restaurant],
        for user: User,
        topN: Int = 3 // adjust as needed
    ) -> RecommendationResult {
        var eligible: [RestaurantRecommendation] = []
        var excluded: [ExcludedRestaurant] = []
        
        for restaurant in restaurants {
            if let reason = exclusionReason(for: restaurant, user: user) {
                excluded.append(
                    ExcludedRestaurant(restaurant: restaurant, reason: reason)
                )
                continue
            }
            
            eligible.append(
                RestaurantRecommendation(restaurant: restaurant, scores: calculateScore(restaurant, user))
            )
        }
        
        eligible.sort {
            if $0.scores.finalScore == $1.scores.finalScore {
                return $0.restaurant.restaurantName < $1.restaurant.restaurantName
            }
            return $0.scores.finalScore > $1.scores.finalScore
        }
        
        return RecommendationResult(
            recommendations: Array(eligible.prefix(max(0, topN))),
            excluded: excluded
        )
    }
}
