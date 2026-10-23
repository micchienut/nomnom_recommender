//
//  RecommendationViewModel.swift
//  Nomnom Recommender
//
//  Created by Edbert Eldon Leopard on 22/10/26.
//

import Foundation
import Observation

// MARK: - Recommendation View Model
@Observable
final class RecommendationViewModel {
    private(set) var restaurants: [Restaurant] = []
    private(set) var loadError: String?
    private(set) var result: RecommendationResult?

    var service = RecommendationService()
    var topN = 3

    init(filename: String = "places") {
        loadRestaurants(from: filename)
    }
}

// MARK: Data Loading
extension RecommendationViewModel {
    func loadRestaurants(from filename: String = "places") {
        do {
            restaurants = try JSONDataLoader.load([Restaurant].self, from: filename)
            loadError = nil
        } catch {
            restaurants = []
            loadError = String(describing: error)
        }
    }
}

// MARK: Recommend
extension RecommendationViewModel {
    func recommend(for user: User) {
        result = service.recommend(
            restaurants: restaurants,
            for: user,
            topN: topN
        )
    }
}
