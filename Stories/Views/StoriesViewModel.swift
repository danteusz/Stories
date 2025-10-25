//
//  StoriesViewModel.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import SwiftUI

@MainActor
final class StoriesViewModel: ObservableObject {
    @Published private(set) var stories: [Story] = []
    @Published private(set) var seen: Set<UUID>
    @Published private(set) var liked: Set<UUID>
    @Published var currentIndex: Int = 0

    let navigationTitle = "Stories"

    private let persistence = StoriesPersistence()
    private let dataSource = StoryDataSource()

    init() {
        stories = dataSource.loadStories()
        seen = persistence.loadSeen()
        liked = persistence.loadLiked()
    }

    func markSeen(_ story: Story) {
        seen.insert(story.id)
        persistence.saveSeen(seen)
    }

    func toggleLike(_ item: StoryItem) {
        if liked.contains(item.id) {
            liked.remove(item.id)
        } else {
            liked.insert(item.id)
        }
        persistence.saveLiked(liked)
    }

    func isLiked(_ item: StoryItem) -> Bool {
        liked.contains(item.id)
    }

    func isSeen(_ story: Story) -> Bool {
        seen.contains(story.id)
    }

    func loadMore() {
        let newStories = dataSource.loadStories()
        stories.append(contentsOf: newStories)
    }

    func photoURL(for item: StoryItem) -> URL? {
        URL(string: "https://picsum.photos/seed/\(item.seed)/800/1200")
    }

    func avatarUrl(for story: Story) -> URL? {
        let size = Int(Style.Sizes.avatarSize * UIScreen.main.scale)
        return URL(string: "https://picsum.photos/seed/\(story.id)/\(size)")
    }

    func next(in story: Story) {
        if currentIndex < story.items.count - 1 {
            currentIndex += 1
        }
    }

    func previous(in _: Story) {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }

    func currentItem(in story: Story) -> StoryItem? {
        guard currentIndex < story.items.count else { return nil }
        return story.items[currentIndex]
    }

    func progress(for index: Int) -> Double {
        index < currentIndex ? 1 : index == currentIndex ? 0.3 : 0
    }
}
