//
//  GroupSessionViewModel.swift
//  Nomnom Recommender
//
//  Created by Michelle Nathania on 23/10/26.
//

import Foundation
import Observation

// MARK: - Group Session View Model
@Observable
final class GroupSessionViewModel {
    private(set) var group = GroupPreferences()

    var destination: Destination?
    var maxDistanceM: Double = 1_000

    var canRecommend: Bool {
        group.memberCount > 0 && destination != nil
    }
}

// MARK: Actions
extension GroupSessionViewModel {
    // Only the aggregate is kept, the user is dropped after this call
    func addMember(_ user: User) {
        group.add(user)
    }

    func reset() {
        group = GroupPreferences()
    }
}
