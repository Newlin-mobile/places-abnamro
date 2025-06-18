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
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .focused($isNameFieldFocused)
                .submitLabel(.done)
            HStack {
                Button("Cancel") { onCancel() }
                Spacer()
                Button("Add") { onAdd() }
                    .disabled(newLocationName.trimmingCharacters(in: .whitespaces).isEmpty)
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
