//
//  GroupSessionView.swift
//  Nomnom Recommender
//
//  Created by Michelle Nathania on 23/10/26.
//

import SwiftUI

// MARK: - Group Session
struct GroupSessionView: View {
    @Bindable var session: GroupSessionViewModel
    @Bindable var recommendations: RecommendationViewModel

    @State private var showMemberSheet = false
    @State private var showResults = false

    var body: some View {
        Form {
            if let error = recommendations.loadError {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }

            destinationSection
            membersSection
            aggregateSection

            Section {
                Button {
                    if let destination = session.destination {
                        recommendations.recommend(
                            for: session.group,
                            near: destination,
                            withinMeters: session.maxDistanceM
                        )
                        showResults = true
                    }
                } label: {
                    Text("Get Group Recommendations")
                        .frame(maxWidth: .infinity)
                }
                .disabled(!session.canRecommend)
            }
        }
        .navigationTitle("Group Tester")
        .toolbar {
            Button("Reset", role: .destructive) {
                session.reset()
            }
        }
        .sheet(isPresented: $showMemberSheet) {
            MemberPreferencesSheet { user in
                session.addMember(user)
            }
        }
        .navigationDestination(isPresented: $showResults) {
            RecommendationResultsView(result: recommendations.result, topN: recommendations.topN)
        }
    }
}

// MARK: Sections
private extension GroupSessionView {
    var destinationSection: some View {
        Section {
            Picker("Destination", selection: $session.destination) {
                Text("Not set").tag(Destination?.none)
                ForEach(recommendations.destinations) { destination in
                    Text(destination.name).tag(Optional(destination))
                }
            }
            Stepper(
                "Within \(Int(session.maxDistanceM)) m",
                value: $session.maxDistanceM,
                in: 200...2_000,
                step: 100
            )
        } header: {
            Text("Destination")
        } footer: {
            Text("Only restaurants near the destination are considered.")
        }
    }

    var membersSection: some View {
        Section {
            LabeledContent("Members", value: "\(session.group.memberCount)")
            Button("Add Member") {
                showMemberSheet = true
            }
        } header: {
            Text("Members")
        } footer: {
            Text("Each member's answers are merged into the group totals and discarded. Names are never saved.")
        }
    }

    // Shows exactly what the recommender sees, to check nothing identifies a member
    @ViewBuilder
    var aggregateSection: some View {
        if session.group.memberCount > 0 {
            let group = session.group

            Section("Aggregated Preferences") {
                aggregateRow("Dietary", group.dietaryRestrictions)
                aggregateRow("Allergens", group.allergensToAvoid)
                aggregateRow("Disliked ingredients", group.dislikedIngredients)
                aggregateRow("Disliked tags", group.dislikedFoodTags)
                voteRow("Cuisine votes", group.cuisineVotes)
                voteRow("Tag votes", group.foodTagVotes)
                LabeledContent(
                    "Budget",
                    value: "\(group.budgetMinIDR.formattedIDR) – \(group.budgetMaxIDR.formattedIDR)"
                )
            }
        }
    }

    func aggregateRow(_ title: String, _ ids: Set<String>) -> some View {
        LabeledContent(title, value: ids.isEmpty ? "None" : ids.sorted().map(PreferenceOptions.label(for:)).joined(separator: ", "))
    }

    func voteRow(_ title: String, _ votes: [String: Int]) -> some View {
        LabeledContent(
            title,
            value: votes.isEmpty
                ? "None"
                : votes.sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }
                    .map { "\(PreferenceOptions.label(for: $0.key)) ×\($0.value)" }
                    .joined(separator: ", ")
        )
    }
}

// MARK: - Member Preferences Sheet
private struct MemberPreferencesSheet: View {
    let onSubmit: (User) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var preferences = PreferencesViewModel()

    var body: some View {
        NavigationStack {
            Form {
                PreferencesSectionsView(preferences: preferences)
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        onSubmit(preferences.makeUser())
                        dismiss()
                    }
                    .disabled(!preferences.isBudgetValid)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GroupSessionView(
            session: GroupSessionViewModel(),
            recommendations: RecommendationViewModel()
        )
    }
}
