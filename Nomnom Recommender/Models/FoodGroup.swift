//
//  FoodGroup.swift
//  Nomnom Recommender
//
//  Created by Michelle Nathania on 23/10/26.
//

import Foundation

struct FoodGroup: Identifiable {
    let groupID: String
    var groupName: String
    var members: [User]
    
    var id: String { groupID }
}
