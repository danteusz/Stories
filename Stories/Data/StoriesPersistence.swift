//
//  StoriesPersistence.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import Foundation


protocol StoriesPersistenceProtocol {
    func loadSeen() -> Set<String>
    func saveSeen(_ seen: Set<String>)
    func loadLiked() -> Set<String>
    func saveLiked(_ liked: Set<String>)
}

final class StoriesPersistence: StoriesPersistenceProtocol {
    private let seenKey = "seenStories"
    private let likedKey = "likedStories"

    func loadSeen() -> Set<String> {
        guard let data = UserDefaults.standard.array(forKey: seenKey) as? [String] else { return [] }
        return Set(data)
    }

    func saveSeen(_ seen: Set<String>) {
        let data = seen.map { $0 }
        UserDefaults.standard.set(data, forKey: seenKey)
    }

    func loadLiked() -> Set<String> {
        guard let data = UserDefaults.standard.array(forKey: likedKey) as? [String] else { return [] }
        return Set(data)
    }

    func saveLiked(_ liked: Set<String>) {
        let data = liked.map { $0 }
        UserDefaults.standard.set(data, forKey: likedKey)
    }
}
