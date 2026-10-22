//
//  PreferenceOptions.swift
//  Nomnom Recommender
//
//  Created by Edbert Eldon Leopard on 22/10/26.
//

import Foundation

// MARK: - Preference Option
// id is the raw value compared by RecommendationService and used in restaurants.json
struct PreferenceOption: Identifiable, Hashable {
    let id: String
    let label: String
}

// MARK: - Budget Preset
struct BudgetPreset: Identifiable, Hashable {
    let id: String
    let label: String
    let minIDR: Double
    let maxIDR: Double
}

// MARK: - Predefined Options
enum PreferenceOptions {
    // Restrictions
    static let dietaryRestrictions: [PreferenceOption] = [
        .init(id: "halal_only", label: "Halal only"),
        .init(id: "vegetarian", label: "Vegetarian"),
        .init(id: "vegan", label: "Vegan"),
        .init(id: "pescatarian", label: "Pescatarian")
    ]

    static let allergens: [PreferenceOption] = [
        .init(id: "peanuts", label: "Peanuts"),
        .init(id: "tree_nuts", label: "Tree nuts"),
        .init(id: "shellfish", label: "Shellfish"),
        .init(id: "fish", label: "Fish"),
        .init(id: "eggs", label: "Eggs"),
        .init(id: "dairy", label: "Dairy"),
        .init(id: "soy", label: "Soy"),
        .init(id: "gluten", label: "Gluten"),
        .init(id: "sesame", label: "Sesame")
    ]

    static let ingredients: [PreferenceOption] = [
        .init(id: "pork", label: "Pork"),
        .init(id: "lard", label: "Lard"),
        .init(id: "beef", label: "Beef"),
        .init(id: "chicken", label: "Chicken"),
        .init(id: "duck", label: "Duck"),
        .init(id: "lamb", label: "Lamb / goat"),
        .init(id: "offal", label: "Offal"),
        .init(id: "fish", label: "Fish"),
        .init(id: "shellfish", label: "Shellfish"),
        .init(id: "dairy", label: "Dairy"),
        .init(id: "eggs", label: "Eggs"),
        .init(id: "honey", label: "Honey")
    ]

    // Preferences
    static let cuisines: [PreferenceOption] = [
        .init(id: "indonesian", label: "Indonesian"),
        .init(id: "sundanese", label: "Sundanese"),
        .init(id: "javanese", label: "Javanese"),
        .init(id: "padang", label: "Padang"),
        .init(id: "betawi", label: "Betawi"),
        .init(id: "manado", label: "Manado"),
        .init(id: "chinese", label: "Chinese"),
        .init(id: "japanese", label: "Japanese"),
        .init(id: "korean", label: "Korean"),
        .init(id: "western", label: "Western"),
        .init(id: "italian", label: "Italian"),
        .init(id: "thai", label: "Thai"),
        .init(id: "indian", label: "Indian"),
        .init(id: "middle_eastern", label: "Middle Eastern")
    ]

    static let foodTags: [PreferenceOption] = [
        .init(id: "spicy", label: "Spicy"),
        .init(id: "sambal", label: "Sambal"),
        .init(id: "soup", label: "Soup"),
        .init(id: "noodles", label: "Noodles"),
        .init(id: "rice", label: "Rice"),
        .init(id: "grilled", label: "Grilled"),
        .init(id: "fried", label: "Fried"),
        .init(id: "seafood", label: "Seafood"),
        .init(id: "street_food", label: "Street food"),
        .init(id: "coffee", label: "Coffee"),
        .init(id: "dessert", label: "Dessert"),
        .init(id: "bakery", label: "Bakery"),
        .init(id: "healthy", label: "Healthy"),
        .init(id: "comfort_food", label: "Comfort food"),
        .init(id: "sweet", label: "Sweet")
    ]

    static let spiceLevels: [PreferenceOption] = [
        .init(id: "none", label: "Not at all"),
        .init(id: "mild", label: "Mild"),
        .init(id: "medium", label: "Medium"),
        .init(id: "hot", label: "Hot"),
        .init(id: "extra_hot", label: "Extra hot")
    ]

    // Budget
    static let budgetPresets: [BudgetPreset] = [
        .init(id: "under_25k", label: "< 25k", minIDR: 0, maxIDR: 25_000),
        .init(id: "25k_50k", label: "25–50k", minIDR: 25_000, maxIDR: 50_000),
        .init(id: "50k_100k", label: "50–100k", minIDR: 50_000, maxIDR: 100_000),
        .init(id: "over_100k", label: "100k+", minIDR: 100_000, maxIDR: 500_000)
    ]
}

// MARK: Label Lookup
extension PreferenceOptions {
    private static let labelsByID: [String: String] = Dictionary(
        (dietaryRestrictions + allergens + ingredients + cuisines + foodTags + spiceLevels)
            .map { ($0.id, $0.label) },
        uniquingKeysWith: { first, _ in first }
    )

    static func label(for id: String) -> String {
        labelsByID[id] ?? id.replacingOccurrences(of: "_", with: " ").capitalized
    }
}
