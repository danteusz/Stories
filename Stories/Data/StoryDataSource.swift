//
//  StoryDataSource.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import Foundation

final class StoryDataSource {
    func loadStories() -> [Story] {
        if let stories = loadFromBundle() {
            return stories
        } else {
            return generateMockStories()
        }
    }

    private func loadFromBundle() -> [Story]? {
        guard let url = Bundle.main.url(forResource: "stories", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([Story].self, from: data)
    }

    private func generateMockStories() -> [Story] {
        (0 ..< 5).map { i in
            Story(id: UUID(), author: "User_\(i)", items: (0 ..< 3).map { j in
                StoryItem(id: UUID(), title: "Story \(i)-\(j)", seed: "seed_\(i)_\(j)", duration: 5)
            })
        }
    }
}
