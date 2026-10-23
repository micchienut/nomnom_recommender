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
    @State private var groupSession = GroupSessionViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                PreferencesFormView(
                    preferences: preferences,
                    recommendations: recommendations
                )
            }
            .tabItem { Label("Solo", systemImage: "person") }

            NavigationStack {
                GroupSessionView(
                    session: groupSession,
                    recommendations: recommendations
                )
            }
            .tabItem { Label("Group", systemImage: "person.3") }
        }
    }
}

#Preview {
    ContentView()
}
