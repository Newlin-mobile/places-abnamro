//
//  AddLocationSheet.swift
//  places
//
//  Created by Ronald Kuiper on 17/06/2025.
//

import SwiftUI
import MapKit

struct AddLocationSheet: View {
    @Binding var newLocationName: String
    @FocusState private var isNameFieldFocused: Bool
    var onAdd: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Location")
                .font(.headline)
            TextField("Name", text: $newLocationName)
                .accessibilityLabel("Location name")
                .accessibilityHint("Enter the name for the new location")
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .focused($isNameFieldFocused)
                .submitLabel(.done)
            HStack {
                Button("Cancel") { onCancel() }
                    .accessibilityHint("Cancels adding a new location")
                Spacer()
                Button("Add") { onAdd() }
                    .disabled(newLocationName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityHint("Adds the new location")
            }
            .padding([.leading, .trailing, .bottom])
        }
        .padding()
        .presentationDetents([.medium])
        .task {
            // This is often more reliable than onAppear
            isNameFieldFocused = true
        }
    }
}
