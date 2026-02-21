//
//  CharactersViewModel.swift
//  RickAndMortyApp
//
//  Created by Fai on 20/02/26.
//

import Foundation
import Combine

@MainActor
class CharactersViewModel: ObservableObject {
    @Published var characters: [RMCharacter] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    @Published var hasNext: Bool = false
    @Published var hasPrev: Bool = false
    var currentPage: Int = 1

    private let apiService = RMAPIService()

    func loadFirstPage() async {
        currentPage = 1
        await loadPage(page: currentPage)
    }

    func loadNextPage() async {
        if hasNext {
            currentPage += 1
            await loadPage(page: currentPage)
        }
    }
    
    func loadPrevPage() async {
        if hasPrev {
            currentPage -= 1
            await loadPage(page: currentPage)
        }
    }

    func loadPage(page: Int) async {
        isLoading = true
        errorMessage = ""

        let nameFilter = searchText.isEmpty ? nil : searchText

        do {
            let response = try await apiService.fetchCharacters(page: page, name: nameFilter)
            
            self.characters = response.results
            self.hasNext = response.info.next != nil
            self.hasPrev = response.info.prev != nil
            
        } catch let apiError as RMAPIError {
            if apiError == .noResults {
                characters = []
                errorMessage = "No characters found."
                hasNext = false
                hasPrev = false
            } else {
                errorMessage = "Network error. Try again."
            }
        } catch {
            errorMessage = "Something went wrong."
        }

        isLoading = false
    }
}
