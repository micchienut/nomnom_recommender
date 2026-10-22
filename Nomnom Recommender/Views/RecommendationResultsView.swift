//
//  RecommendationResultsView.swift
//  Nomnom Recommender
//
//  Created by Edbert Eldon Leopard on 22/10/26.
//

import SwiftUI

// MARK: - Recommendation Results
struct RecommendationResultsView: View {
    let viewModel: RecommendationViewModel

    var body: some View {
        Group {
            if let result = viewModel.result {
                List {
                    Section {
                        if result.recommendations.isEmpty {
                            ContentUnavailableView(
                                "No Matches",
                                systemImage: "fork.knife",
                                description: Text("Every restaurant was excluded. Loosen your restrictions and try again.")
                            )
                        } else {
                            ForEach(Array(result.recommendations.enumerated()), id: \.element.id) { index, recommendation in
                                RestaurantRowView(
                                    restaurant: recommendation.restaurant,
                                    scores: recommendation.scores,
                                    rank: index + 1
                                )
                            }
                        }
                    } header: {
                        Text("Recommended (top \(viewModel.topN))")
                    }

                    if !result.excluded.isEmpty {
                        Section("Excluded (\(result.excluded.count))") {
                            ForEach(result.excluded) { item in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.restaurant.restaurantName)
                                        .font(.subheadline.weight(.semibold))
                                    Text(item.reason)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Results Yet",
                    systemImage: "sparkle.magnifyingglass",
                    description: Text("Set your preferences and tap Get Recommendations.")
                )
            }
        }
        .navigationTitle("Results")
    }
}

#Preview {
    let preferences = PreferencesViewModel()
    let viewModel = RecommendationViewModel()
    preferences.dietaryRestrictions = ["halal_only"]
    preferences.preferredCuisine = ["sundanese", "indonesian"]
    preferences.preferredFoodTags = ["spicy"]
    viewModel.recommend(for: preferences.makeUser())

    return NavigationStack {
        RecommendationResultsView(viewModel: viewModel)
    }
}
