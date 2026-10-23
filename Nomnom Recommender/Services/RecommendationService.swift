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
    var warnings: [String] = [] // restrictions this restaurant may violate, only set for fallback picks
    
    var id: String { restaurant.id }
}

// MARK: Excluded (not in current IA)
struct ExcludedRestaurant: Identifiable {
    let restaurant: Restaurant
    let violations: [String]
    
    var reason: String { violations.joined(separator: "; ") }
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
    private func violations(
        for restaurant: Restaurant,
        user: User
    ) -> [String] {
        var violations: [String] = []
        
        // Allergens
        let allergens = overlap(restaurant.allergensPresent ?? [], user.allergensToAvoid ?? [])
        if !allergens.isEmpty {
            violations.append("Contains allergens: " +
            allergens.sorted().joined(separator: ", "))
        }
        
        // Ingredients
        let ingredients = overlap(restaurant.ingredientFlags ?? [], user.dislikedIngredients ?? [])
        if !ingredients.isEmpty {
            violations.append("Contains disliked ingredients: " +
            ingredients.sorted().joined(separator: ", "))
        }
        
        // Tags
        let tags = overlap(restaurant.localSpecialtyTags ?? [], user.dislikedFoodTags ?? [])
        if !tags.isEmpty {
            violations.append("Contains disliked tags: " +
            tags.sorted().joined(separator: ", "))
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
                violations.append("Halal status '\(restaurant.halalStatus ?? "Unknown")' does not meet the user's requirement.")
            }
        }
        
        // Vegetarian
        if restrictions.contains("vegetarian") {
            if !options.contains("vegetarian_options") &&
                !options.contains("vegan_options") {
                violations.append("No vegetarian or vegan options available.")
            }
            
            let meatFlags: Set<String> = [
                "pork", "lard", "beef", "chicken", "duck",
                "lamb", "offal", "fish", "shellfish"
            ]
            
            let conflicts = ingredientsPresent.intersection(meatFlags)
            
            if !conflicts.isEmpty {
                violations.append("Contains non-vegetarian ingredient flags: " +
                conflicts.sorted().joined(separator: ", "))
            }
        }
        
        // Vegan
        if restrictions.contains("vegan") {
            if !options.contains("vegan_options") {
                violations.append("No vegan options available.")
            }
            
            let nonVeganFlags: Set<String> = [
                "pork", "lard", "beef", "chicken", "duck",
                "lamb", "offal", "fish", "shellfish",
                "dairy", "eggs", "honey"
            ]
            
            let conflicts = ingredientsPresent.intersection(nonVeganFlags)
            
            if !conflicts.isEmpty {
                violations.append("Contains non-vegan ingredient flags: " +
                conflicts.sorted().joined(separator: ", "))
            }
        }
        
        // Pescatarian
        if restrictions.contains("pescatarian") {
            if !options.contains("pescatarian_options")
                && !options.contains("vegan_options") {
                violations.append("No pescatarian options available.")
            }
            
            let nonPescatarianFlags: Set<String> = [
                "pork", "lard", "beef", "chicken", "duck",
                "lamb", "offal"
            ]
            
            let conflicts = ingredientsPresent.intersection(nonPescatarianFlags)
            
            if !conflicts.isEmpty {
                violations.append("Contains non-pescatarian ingredient flags: " +
                conflicts.sorted().joined(separator: ", "))
            }
        }
        
        return violations
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
        topN: Int = 10 // adjust as needed
    ) -> RecommendationResult {
        rank(
            restaurants,
            topN: topN,
            violations: { violations(for: $0, user: user) },
            calculateScore: { calculateScore($0, user) }
        )
    }
    
    // Restaurants that break a restriction only fill spots the clean matches leave open, fewest warnings first
    private func rank(
        _ restaurants: [Restaurant],
        topN: Int,
        violations: (Restaurant) -> [String],
        calculateScore: (Restaurant) -> RecommendationScores
    ) -> RecommendationResult {
        var eligible: [RestaurantRecommendation] = []
        var fallback: [RestaurantRecommendation] = []
        var excluded: [ExcludedRestaurant] = []
        
        for restaurant in restaurants {
            let found = violations(restaurant)
            let scores = calculateScore(restaurant)
            
            if found.isEmpty {
                eligible.append(
                    RestaurantRecommendation(restaurant: restaurant, scores: scores)
                )
            } else {
                excluded.append(
                    ExcludedRestaurant(restaurant: restaurant, violations: found)
                )
                fallback.append(
                    RestaurantRecommendation(restaurant: restaurant, scores: scores, warnings: found)
                )
            }
        }
        
        eligible.sort(by: ranksHigher)
        fallback.sort {
            if $0.warnings.count == $1.warnings.count {
                return ranksHigher($0, $1)
            }
            return $0.warnings.count < $1.warnings.count
        }
        
        let count = max(0, topN)
        
        return RecommendationResult(
            recommendations: Array((eligible + fallback).prefix(count)),
            excluded: excluded
        )
    }
    
    private func ranksHigher(
        _ first: RestaurantRecommendation,
        _ second: RestaurantRecommendation
    ) -> Bool {
        if first.scores.finalScore == second.scores.finalScore {
            return first.restaurant.restaurantName < second.restaurant.restaurantName
        }
        return first.scores.finalScore > second.scores.finalScore
    }
}

// MARK: - Group
// MARK: Destination Filter
extension RecommendationService {
    func nearby(
        _ restaurants: [Restaurant],
        landmarkID: String,
        withinMeters maxDistanceM: Double
    ) -> [Restaurant] {
        restaurants.filter {
            $0.landmarkID == landmarkID && ($0.distanceM ?? .infinity) <= maxDistanceM
        }
    }
}

// MARK: Group Proxy User
// Carries the group's restrictions and budget so the single-user rules can be reused as they are
extension RecommendationService {
    private func proxyUser(for group: GroupPreferences) -> User {
        User(
            userID: "group",
            username: "group",
            name: "Group",
            dietaryRestrictions: group.dietaryRestrictions.sorted(),
            allergensToAvoid: group.allergensToAvoid.sorted(),
            dislikedIngredients: group.dislikedIngredients.sorted(),
            dislikedFoodTags: group.dislikedFoodTags.sorted(),
            budgetMinIDR: group.budgetMinIDR,
            budgetMaxIDR: group.budgetMaxIDR
        )
    }
}

// MARK: Group Cuisine Score
extension RecommendationService {
    private func cuisineScore(
        _ restaurant: Restaurant,
        _ group: GroupPreferences
    ) -> Double {
        guard !group.cuisineVotes.isEmpty else {
            return 0.5
        }
        
        // Most votes on any one of its cuisines = members it surely suits, without counting anyone twice
        let votes = (restaurant.cuisine ?? []).map { group.cuisineVotes[$0] ?? 0 }.max() ?? 0
        
        return Double(votes) / Double(max(group.memberCount, 1))
    }
}

// MARK: Group Food Tag Score
extension RecommendationService {
    private func foodTagScore(
        _ restaurant: Restaurant,
        _ group: GroupPreferences
    ) -> Double {
        guard !group.foodTagVotes.isEmpty else {
            return 0.5
        }
        
        let votes = (restaurant.localSpecialtyTags ?? []).map { group.foodTagVotes[$0] ?? 0 }.max() ?? 0
        
        return Double(votes) / Double(max(group.memberCount, 1))
    }
}

// MARK: Group Output
extension RecommendationService {
    func recommend(
        restaurants: [Restaurant],
        for group: GroupPreferences,
        topN: Int = 10
    ) -> RecommendationResult {
        let proxy = proxyUser(for: group)
        
        return rank(
            restaurants,
            topN: topN,
            violations: { violations(for: $0, user: proxy) },
            calculateScore: { restaurant in
                let cuisine = cuisineScore(restaurant, group)
                let foodTags = foodTagScore(restaurant, group)
                let budget = budgetScore(restaurant, proxy)
                
                return RecommendationScores(
                    cuisine: cuisine,
                    foodTags: foodTags,
                    budget: budget,
                    finalScore: (cuisine + foodTags + budget) / 3.0
                )
            }
        )
    }
}
