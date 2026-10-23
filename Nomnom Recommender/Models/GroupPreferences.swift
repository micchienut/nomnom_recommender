//
//  GroupPreferences.swift
//  Nomnom Recommender
//
//  Created by Michelle Nathania on 23/10/26.
//

import Foundation

// MARK: - Group Preferences
// Aggregated view of a group. Stores no userID / name and nothing per member,
// so nobody can tell who has which restriction.
struct GroupPreferences {
    private(set) var memberCount = 0

    // Restrictions (union: everyone's restriction applies to the whole group)
    private(set) var dietaryRestrictions: Set<String> = []
    private(set) var allergensToAvoid: Set<String> = []
    private(set) var dislikedIngredients: Set<String> = []
    private(set) var dislikedFoodTags: Set<String> = []

    // Preferences (votes: how many members picked it)
    private(set) var cuisineVotes: [String: Int] = [:]
    private(set) var foodTagVotes: [String: Int] = [:]

    // Budget (tightest range that still fits the cheapest member)
    private(set) var budgetMinIDR: Double = 0
    private(set) var budgetMaxIDR: Double = 0
}

// MARK: Add Member
extension GroupPreferences {
    // The user is folded into the totals and not kept
    mutating func add(_ user: User) {
        dietaryRestrictions.formUnion(user.dietaryRestrictions ?? [])
        allergensToAvoid.formUnion(user.allergensToAvoid ?? [])
        dislikedIngredients.formUnion(user.dislikedIngredients ?? [])
        dislikedFoodTags.formUnion(user.dislikedFoodTags ?? [])

        for cuisine in Set(user.preferredCuisine ?? []) {
            cuisineVotes[cuisine, default: 0] += 1
        }
        for tag in Set(user.preferredFoodTags ?? []) {
            foodTagVotes[tag, default: 0] += 1
        }

        if memberCount == 0 {
            budgetMinIDR = user.budgetMinIDR
            budgetMaxIDR = user.budgetMaxIDR
        } else {
            budgetMinIDR = min(budgetMinIDR, user.budgetMinIDR)
            budgetMaxIDR = min(budgetMaxIDR, user.budgetMaxIDR)
        }

        memberCount += 1
    }
}
