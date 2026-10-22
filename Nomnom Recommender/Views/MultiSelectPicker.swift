//
//  MultiSelectPicker.swift
//  Nomnom Recommender
//
//  Created by Edbert Eldon Leopard on 22/10/26.
//

import SwiftUI

// MARK: - Multi Select Picker
struct MultiSelectPicker: View {
    let title: String
    let options: [PreferenceOption]
    @Binding var selection: Set<String>

    var body: some View {
        NavigationLink {
            MultiSelectList(title: title, options: options, selection: $selection)
        } label: {
            LabeledContent(title, value: summary)
        }
    }

    private var summary: String {
        switch selection.count {
        case 0:
            return "None"
        case 1:
            return PreferenceOptions.label(for: selection.first ?? "")
        default:
            return "\(selection.count) selected"
        }
    }
}

// MARK: - Multi Select List
private struct MultiSelectList: View {
    let title: String
    let options: [PreferenceOption]
    @Binding var selection: Set<String>

    var body: some View {
        List(options) { option in
            Button {
                toggle(option.id)
            } label: {
                HStack {
                    Text(option.label)
                    Spacer()
                    if selection.contains(option.id) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
                    }
                }
                .contentShape(Rectangle())
            }
            .foregroundStyle(.primary)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !selection.isEmpty {
                Button("Clear") { selection.removeAll() }
            }
        }
    }

    private func toggle(_ id: String) {
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
    }
}

#Preview {
    @Previewable @State var selection: Set<String> = ["sundanese"]

    NavigationStack {
        Form {
            MultiSelectPicker(
                title: "Cuisine",
                options: PreferenceOptions.cuisines,
                selection: $selection
            )
        }
    }
}
