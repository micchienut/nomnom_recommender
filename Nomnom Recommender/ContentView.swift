//
//  ContentView.swift
//  Nomnom Recommender
//
//  Created by Michelle Nathania on 21/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var preferences = PreferencesViewModel()
    @State private var recommendations = RecommendationViewModel()

    var body: some View {
        NavigationStack {
            PreferencesFormView(
                preferences: preferences,
                recommendations: recommendations
            )
        }
    }
}

#Preview {
    ContentView()
}
