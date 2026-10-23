//
//  PreferencesFormView.swift
//  Nomnom Recommender
//
//  Created by Edbert Eldon Leopard on 22/10/26.
//

import SwiftUI

// MARK: - Preferences Form
struct PreferencesFormView: View {
    @Bindable var preferences: PreferencesViewModel
    @Bindable var recommendations: RecommendationViewModel

    @State private var showResults = false

    var body: some View {
        Form {
            if let error = recommendations.loadError {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }

            PreferencesSectionsView(preferences: preferences)
            testSettingsSection

            Section {
                Button {
                    recommendations.recommend(for: preferences.makeUser())
                    showResults = true
                } label: {
                    Text("Get Recommendations")
                        .frame(maxWidth: .infinity)
                }
                .disabled(!preferences.isBudgetValid || recommendations.restaurants.isEmpty)
            }
        }
        .navigationTitle("Nomnom Tester")
        .toolbar {
            Button("Reset", role: .destructive) {
                preferences.reset()
            }
        }
        .navigationDestination(isPresented: $showResults) {
            RecommendationResultsView(result: recommendations.result, topN: recommendations.topN)
        }
    }
}

// MARK: Sections
private extension PreferencesFormView {
    var testSettingsSection: some View {
        Section {
            Toggle("Accept halal_claimed", isOn: $recommendations.service.acceptHalalClaimed)
            Stepper(
                "Top \(recommendations.topN)",
                value: $recommendations.topN,
                in: 1...max(1, recommendations.restaurants.count)
            )
        } header: {
            Text("Test Settings")
        } footer: {
            Text("\(recommendations.restaurants.count) restaurants loaded from restaurants.json")
        }
    }
}

#Preview {
    NavigationStack {
        PreferencesFormView(
            preferences: PreferencesViewModel(),
            recommendations: RecommendationViewModel()
        )
    }
}
