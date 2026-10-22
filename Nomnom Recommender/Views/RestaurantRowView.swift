//
//  RestaurantRowView.swift
//  Nomnom Recommender
//
//  Created by Edbert Eldon Leopard on 22/10/26.
//

import SwiftUI

// MARK: - Restaurant Row
struct RestaurantRowView: View {
    let restaurant: Restaurant
    var scores: RecommendationScores? = nil
    var rank: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                Spacer()
                if let scores {
                    Text(scores.finalScore, format: .percent.precision(.fractionLength(0)))
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.tint)
                }
            }

            Text(labels(restaurant.cuisine))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text("\(restaurant.priceMinIDR.formattedIDR) – \(restaurant.priceMaxIDR.formattedIDR)")
                    .font(.caption.monospacedDigit())
                HalalBadge(status: restaurant.halalStatus)
            }

            if let tags = restaurant.localSpecialtyTags, !tags.isEmpty {
                Text(labels(tags))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let scores {
                HStack(spacing: 12) {
                    ScoreBar(label: "Cuisine", value: scores.cuisine)
                    ScoreBar(label: "Tags", value: scores.foodTags)
                    ScoreBar(label: "Budget", value: scores.budget)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }

    private var title: String {
        if let rank {
            return "\(rank). \(restaurant.restaurantName)"
        }
        return restaurant.restaurantName
    }

    private func labels(_ ids: [String]?) -> String {
        (ids ?? []).map { PreferenceOptions.label(for: $0) }.joined(separator: " · ")
    }
}

// MARK: - Halal Badge
private struct HalalBadge: View {
    let status: String?

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundStyle(color)
            .background(color.opacity(0.15), in: Capsule())
    }

    private var text: String {
        switch status {
        case "halal_certified": "Halal certified"
        case "halal_claimed": "Halal (claimed)"
        case "non_halal": "Non-halal"
        default: "Halal unknown"
        }
    }

    private var color: Color {
        switch status {
        case "halal_certified": .green
        case "halal_claimed": .teal
        case "non_halal": .red
        default: .gray
        }
    }
}

// MARK: - Score Bar
private struct ScoreBar: View {
    let label: String
    let value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                Spacer()
                Text(value, format: .percent.precision(.fractionLength(0)))
                    .monospacedDigit()
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            ProgressView(value: value)
        }
    }
}

// MARK: - IDR Formatting
extension Double {
    var formattedIDR: String {
        formatted(
            .currency(code: "IDR")
            .locale(Locale(identifier: "id_ID"))
            .precision(.fractionLength(0))
        )
    }
}

#Preview {
    let viewModel = RecommendationViewModel()

    List(viewModel.restaurants) { restaurant in
        RestaurantRowView(restaurant: restaurant)
    }
}
