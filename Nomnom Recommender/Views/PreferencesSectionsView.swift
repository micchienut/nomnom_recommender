//
//  PreferencesSectionsView.swift
//  Nomnom Recommender
//
//  Created by Michelle Nathania on 23/10/26.
//

import SwiftUI

// MARK: - Preferences Sections
// Form sections shared by the solo form and the group member sheet
struct PreferencesSectionsView: View {
    @Bindable var preferences: PreferencesViewModel

    var body: some View {
        restrictionsSection
        preferencesSection
        dislikesSection
        budgetSection
    }
}

// MARK: Sections
private extension PreferencesSectionsView {
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
        Form {
            PreferencesSectionsView(preferences: PreferencesViewModel())
        }
    }
}
