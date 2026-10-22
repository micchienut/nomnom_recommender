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

            restrictionsSection
            preferencesSection
            dislikesSection
            budgetSection
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
            RecommendationResultsView(viewModel: recommendations)
        }
    }
}

// MARK: Sections
private extension PreferencesFormView {
    var restrictionsSection: some View {
        Section {
            MultiSelectPicker(
                title: "Dietary",
                options: PreferenceOptions.dietaryRestrictions,
                selection: $preferences.dietaryRestrictions
            )
            MultiSelectPicker(
                title: "Allergens",
                options: PreferenceOptions.allergens,
                selection: $preferences.allergensToAvoid
            )
        } header: {
            Text("Restrictions")
        } footer: {
            Text("Restaurants that conflict with these are excluded.")
        }
    }

    var preferencesSection: some View {
        Section("Preferences") {
            MultiSelectPicker(
                title: "Cuisine",
                options: PreferenceOptions.cuisines,
                selection: $preferences.preferredCuisine
            )
            MultiSelectPicker(
                title: "Food Tags",
                options: PreferenceOptions.foodTags,
                selection: $preferences.preferredFoodTags
            )
            Picker("Spice Tolerance", selection: $preferences.spiceTolerance) {
                Text("Not set").tag(String?.none)
                ForEach(PreferenceOptions.spiceLevels) { level in
                    Text(level.label).tag(Optional(level.id))
                }
            }
        }
    }

    var dislikesSection: some View {
        Section {
            MultiSelectPicker(
                title: "Ingredients",
                options: PreferenceOptions.ingredients,
                selection: $preferences.dislikedIngredients
            )
            MultiSelectPicker(
                title: "Food Tags",
                options: PreferenceOptions.foodTags,
                selection: $preferences.dislikedFoodTags
            )
        } header: {
            Text("Dislikes")
        } footer: {
            Text("Restaurants flagged with these are excluded.")
        }
    }

    var budgetSection: some View {
        Section {
            Picker("Preset", selection: budgetPresetBinding) {
                ForEach(PreferenceOptions.budgetPresets) { preset in
                    Text(preset.label).tag(Optional(preset))
                }
            }
            .pickerStyle(.segmented)

            LabeledContent("Min (Rp)") {
                TextField("Min", value: $preferences.budgetMinIDR, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            LabeledContent("Max (Rp)") {
                TextField("Max", value: $preferences.budgetMaxIDR, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
        } header: {
            Text("Budget per person")
        } footer: {
            if !preferences.isBudgetValid {
                Text("Max must be greater than 0 and not lower than min.")
                    .foregroundStyle(.red)
            }
        }
    }

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

    var budgetPresetBinding: Binding<BudgetPreset?> {
        Binding(
            get: { preferences.selectedBudgetPreset },
            set: { preset in
                if let preset {
                    preferences.applyBudgetPreset(preset)
                }
            }
        )
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
