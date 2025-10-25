//
//  StoriesPersistence.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import Foundation

final class StoriesPersistence {
    private let seenKey = "seenStories"
    private let likedKey = "likedStories"

    func loadSeen() -> Set<UUID> {
        guard let data = UserDefaults.standard.array(forKey: seenKey) as? [String] else { return [] }
        return Set(data.compactMap { UUID(uuidString: $0) })
    }

    func saveSeen(_ seen: Set<UUID>) {
        let data = seen.map { $0.uuidString }
        UserDefaults.standard.set(data, forKey: seenKey)
    }

    func loadLiked() -> Set<UUID> {
        guard let data = UserDefaults.standard.array(forKey: likedKey) as? [String] else { return [] }
        return Set(data.compactMap { UUID(uuidString: $0) })
    }

    func saveLiked(_ liked: Set<UUID>) {
        let data = liked.map { $0.uuidString }
        UserDefaults.standard.set(data, forKey: likedKey)
    }
}
