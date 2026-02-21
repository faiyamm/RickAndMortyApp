//
//  CharacterDetailView.swift
//  RickAndMortyApp
//
//  Created by Fai on 20/02/26.
//

import SwiftUI

struct CharacterDetailView: View {
    let character: RMCharacter
    private let notesStore = CharacterNotesStore()

    @State private var noteText: String = ""
    @State private var showSavedMessage: Bool = false

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Image
                AsyncImage(url: URL(string: character.image)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Rectangle().fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)

                // Title & Grid Stats
                VStack(spacing: 20) {
                    Text(character.name)
                        .font(.system(size: 32, weight: .heavy))
                        .multilineTextAlignment(.center)

                    LazyVGrid(columns: columns, spacing: 12) {
                        StatCard(icon: "waveform.path.ecg", title: "STATUS", value: character.status, color: statusColor(for: character.status))
                        StatCard(icon: "person.fill", title: "SPECIES", value: character.species, color: .blue)
                        StatCard(icon: "figure.dress.line.vertical.figure", title: "GENDER", value: character.gender, color: .purple)
                        if !character.type.isEmpty {
                            StatCard(icon: "tag.fill", title: "TYPE", value: character.type, color: .orange)
                        }
                    }
                    .padding(.horizontal)
                }

                // Extra Info List
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(label: "Origin", value: character.origin.name)
                    Divider()
                    InfoRow(label: "Location", value: character.location.name)
                    Divider()
                    InfoRow(label: "Episodes", value: "\(character.episode.count) appearances")
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Notes Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Private Note")
                        .font(.headline)

                    TextEditor(text: $noteText)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))

                    HStack {
                        Button {
                            notesStore.saveNote(characterId: character.id, note: noteText)
                            showSavedMessage = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showSavedMessage = false }
                        } label: {
                            Text("Save Note")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)

                        Button(role: .destructive) {
                            noteText = ""
                            notesStore.clearNote(characterId: character.id)
                        } label: {
                            Text("Clear")
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.bordered)
                    }

                    if showSavedMessage {
                        Text("Note saved locally.")
                            .font(.footnote)
                            .foregroundStyle(.green)
                            .transition(.opacity)
                    }
                }
                .padding()
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .padding(.vertical)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            noteText = notesStore.loadNote(characterId: character.id)
            showSavedMessage = false
        }
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "alive": return .green
        case "dead": return .red
        default: return .gray
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).bold().foregroundColor(.secondary)
            Text(value).font(.body).foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
