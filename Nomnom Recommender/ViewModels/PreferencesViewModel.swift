//
//  PreferencesViewModel.swift
//  Nomnom Recommender
//
//  Created by Edbert Eldon Leopard on 22/10/26.
//

import Foundation
import Observation

// MARK: - Preferences View Model
@Observable
final class PreferencesViewModel {
    // Restriction
    var dietaryRestrictions: Set<String> = []
    var allergensToAvoid: Set<String> = []

    // Preferences
    var dislikedIngredients: Set<String> = []
    var dislikedFoodTags: Set<String> = []
    var preferredCuisine: Set<String> = []
    var preferredFoodTags: Set<String> = []
    var spiceTolerance: String?

    var budgetMinIDR: Double = 25_000
    var budgetMaxIDR: Double = 50_000

    var isBudgetValid: Bool {
        budgetMaxIDR > 0 && budgetMinIDR >= 0 && budgetMinIDR <= budgetMaxIDR
    }

    var selectedBudgetPreset: BudgetPreset? {
        PreferenceOptions.budgetPresets.first {
            $0.minIDR == budgetMinIDR && $0.maxIDR == budgetMaxIDR
        }
    }
}

// MARK: Actions
extension PreferencesViewModel {
    func applyBudgetPreset(_ preset: BudgetPreset) {
        budgetMinIDR = preset.minIDR
        budgetMaxIDR = preset.maxIDR
    }

    func reset() {
        dietaryRestrictions = []
        allergensToAvoid = []
        dislikedIngredients = []
        dislikedFoodTags = []
        preferredCuisine = []
        preferredFoodTags = []
        spiceTolerance = nil
        budgetMinIDR = 25_000
        budgetMaxIDR = 50_000
    }
}

// MARK: User Builder
extension PreferencesViewModel {
    func makeUser() -> User {
        User(
            userID: "test_user",
            username: "tester",
            name: "Test User",
            dietaryRestrictions: dietaryRestrictions.sorted(),
            allergensToAvoid: allergensToAvoid.sorted(),
            dislikedIngredients: dislikedIngredients.sorted(),
            dislikedFoodTags: dislikedFoodTags.sorted(),
            preferredCuisine: preferredCuisine.sorted(),
            preferredFoodTags: preferredFoodTags.sorted(),
            spiceTolerance: spiceTolerance,
            budgetMinIDR: budgetMinIDR,
            budgetMaxIDR: budgetMaxIDR
        )
    }
}
