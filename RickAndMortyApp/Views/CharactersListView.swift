//
//  CharactersListView.swift
//  RickAndMortyApp
//
//  Created by Fai on 20/02/26.
//

import SwiftUI

struct CharactersListView: View {
    @StateObject private var viewModel = CharactersViewModel()
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                VStack {
                    if !viewModel.errorMessage.isEmpty {
                        VStack {
                            Text(viewModel.errorMessage).foregroundStyle(.red)
                            Button("Retry") { Task { await viewModel.loadPage(page: viewModel.currentPage) } }
                                .buttonStyle(.bordered)
                        }.padding()
                    }

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.characters) { character in
                                NavigationLink(destination: CharacterDetailView(character: character)) {
                                    CharacterCardView(character: character)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                        
                        // Pagination Footer
                        if !viewModel.characters.isEmpty {
                            HStack {
                                Button("Prev") { Task { await viewModel.loadPrevPage() } }
                                    .disabled(!viewModel.hasPrev)
                                    .buttonStyle(.bordered)
                                
                                Spacer()
                                Text("Page \(viewModel.currentPage)").font(.caption).foregroundStyle(.secondary)
                                Spacer()
                                
                                Button("Next") { Task { await viewModel.loadNextPage() } }
                                    .disabled(!viewModel.hasNext)
                                    .buttonStyle(.bordered)
                            }
                            .padding()
                        }
                    }
                    .refreshable {
                        await viewModel.loadFirstPage()
                    }
                }
            }
            .navigationTitle("Characters")
            .searchable(text: $viewModel.searchText, prompt: "Search by name")
            .onSubmit(of: .search) {
                Task { await viewModel.loadFirstPage() }
            }
            .overlay {
                if viewModel.isLoading && viewModel.characters.isEmpty {
                    ProgressView("Loading...").scaleEffect(1.2)
                }
            }
            .onAppear {
                if viewModel.characters.isEmpty {
                    Task { await viewModel.loadFirstPage() }
                }
            }
        }
    }
}

struct CharacterCardView: View {
    let character: RMCharacter
    
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: character.image)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                        .overlay(ProgressView())
                }
            }
            .frame(height: 160)
            .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                Text(character.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor(for: character.status))
                        .frame(width: 8, height: 8)
                    Text("\(character.status) - \(character.species)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "alive": return .green
        case "dead": return .red
        default: return .gray
        }
    }
}
