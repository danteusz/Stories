//
//  defined.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//


import Foundation

// Conforms to the protocol defined above
final class MockStoriesPersistence: StoriesPersistenceProtocol {
    var seenSet: Set<UUID> = []
    var likedSet: Set<UUID> = []
    var saveSeenCallCount = 0
    var saveLikedCallCount = 0

    func loadSeen() -> Set<UUID> {
        return seenSet
    }

    func saveSeen(_ seen: Set<UUID>) {
        saveSeenCallCount += 1
        seenSet = seen
    }

    func loadLiked() -> Set<UUID> {
        return likedSet
    }

    func saveLiked(_ liked: Set<UUID>) {
        saveLikedCallCount += 1
        likedSet = liked
    }
}