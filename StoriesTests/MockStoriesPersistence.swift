//
//  MockStoriesPersistence.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//


@testable import Stories

// Conforms to the protocol defined above
final class MockStoriesPersistence: StoriesPersistenceProtocol {
    var seenSet: Set<String> = []
    var likedSet: Set<String> = []
    var saveSeenCallCount = 0
    var saveLikedCallCount = 0

    func loadSeen() -> Set<String> {
        return seenSet
    }

    func saveSeen(_ seen: Set<String>) {
        saveSeenCallCount += 1
        seenSet = seen
    }

    func loadLiked() -> Set<String> {
        return likedSet
    }

    func saveLiked(_ liked: Set<String>) {
        saveLikedCallCount += 1
        likedSet = liked
    }
}
