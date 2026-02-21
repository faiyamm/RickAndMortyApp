//
//  RMAPIError.swift
//  RickAndMortyApp
//
//  Created by Fai on 20/02/26.
//

import Foundation

enum RMAPIError: Error {
    case invalidUrl
    case requestFailed
    case invalidResponse
    case badStatusCode
    case noResults
    case decodingFailed
}

class RMAPIService {
    private let baseUrlString: String = "https://rickandmortyapi.com/api/character"
    
    func fetchCharacters(page: Int, name: String?) async throws -> CharacterResponse {
        guard var components = URLComponents(string: baseUrlString) else {
            throw RMAPIError.invalidUrl
        }

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page))
        ]
        
        if let nameValue = name, !nameValue.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: nameValue))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw RMAPIError.invalidUrl
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RMAPIError.invalidResponse
        }

        if httpResponse.statusCode == 404 {
            throw RMAPIError.noResults
        } else if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            throw RMAPIError.badStatusCode
        }
        
        do {
            return try JSONDecoder().decode(CharacterResponse.self, from: data)
        } catch {
            print(String(data: data, encoding: .utf8)?.prefix(200) ?? "Unreadable JSON")
            throw RMAPIError.decodingFailed
        }
    }
}
