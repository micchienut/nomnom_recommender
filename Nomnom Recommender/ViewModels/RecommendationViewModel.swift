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
    var topN = 10

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

// MARK: Destinations
extension RecommendationViewModel {
    var destinations: [Destination] {
        var seen: Set<String> = []
        
        return restaurants.compactMap { restaurant in
            guard let id = restaurant.landmarkID,
                  let name = restaurant.landmarkName,
                  seen.insert(id).inserted else { return nil }
            return Destination(id: id, name: name)
        }
    }
}

// MARK: Recommend for Group
extension RecommendationViewModel {
    func recommend(
        for group: GroupPreferences,
        near destination: Destination,
        withinMeters maxDistanceM: Double
    ) {
        result = service.recommend(
            restaurants: service.nearby(
                restaurants,
                landmarkID: destination.id,
                withinMeters: maxDistanceM
            ),
            for: group,
            topN: topN
        )
    }
}
