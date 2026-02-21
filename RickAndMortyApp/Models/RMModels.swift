//
//  RMModels.swift
//  RickAndMortyApp
//
//  Created by Fai on 20/02/26.
//

import Foundation

struct CharacterResponse: Codable {
    var info: PageInfo
    var results: [RMCharacter]
}

struct PageInfo: Codable {
    var count: Int
    var pages: Int
    var next: String?
    var prev: String?
}

struct RMCharacter: Codable, Identifiable {
    var id: Int
    var name: String
    var status: String
    var species: String
    var type: String
    var gender: String
    var origin: RMPlace
    var location: RMPlace
    var image: String
    var episode: [String]
}

struct RMPlace: Codable {
    var name: String
    var url: String
}
