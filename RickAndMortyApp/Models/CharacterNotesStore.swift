//
//  CharacterNotesStore.swift
//  RickAndMortyApp
//
//  Created by Fai on 20/02/26.
//

import Foundation

class CharacterNotesStore {
    private let userDefaults: UserDefaults = UserDefaults.standard

    private func makeKey(characterId: Int) -> String {
        return "rm_note_\(characterId)"
    }

    func loadNote(characterId: Int) -> String {
        let key = makeKey(characterId: characterId)
        return userDefaults.string(forKey: key) ?? ""
    }

    func saveNote(characterId: Int, note: String) {
        let key = makeKey(characterId: characterId)
        userDefaults.set(note, forKey: key)
    }

    func clearNote(characterId: Int) {
        let key = makeKey(characterId: characterId)
        userDefaults.removeObject(forKey: key)
    }
}
