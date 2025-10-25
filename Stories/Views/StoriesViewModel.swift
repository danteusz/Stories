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
    @Published var currentStoryIndices: [UUID: Int] = [:]
    @Published var shouldNavigateToNext: Story? = nil
    @Published var shouldDismiss: Bool = false

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

    func currentIndex(for story: Story) -> Int {
        currentStoryIndices[story.id] ?? 0
    }

    func next(in story: Story) {
        let currentIdx = currentIndex(for: story)

        if currentIdx < story.items.count - 1 {
            currentStoryIndices[story.id] = currentIdx + 1
        } else {
            // Reached the end of current story, find next story
            if let currentStoryIndex = stories.firstIndex(where: { $0.id == story.id }),
               currentStoryIndex < stories.count - 1
            {
                let nextStory = stories[currentStoryIndex + 1]
                currentStoryIndices[nextStory.id] = 0
                shouldNavigateToNext = nextStory
            } else {
                // This is the last story, dismiss
                shouldDismiss = true
            }
        }
    }

    func previous(in story: Story) {
        let currentIdx = currentIndex(for: story)

        if currentIdx > 0 {
            currentStoryIndices[story.id] = currentIdx - 1
        } else {
            // At the beginning of current story, find previous story
            if let currentStoryIndex = stories.firstIndex(where: { $0.id == story.id }),
               currentStoryIndex > 0
            {
                let previousStory = stories[currentStoryIndex - 1]
                currentStoryIndices[previousStory.id] = previousStory.items.count - 1
                shouldNavigateToNext = previousStory
            }
        }
    }

    func currentItem(in story: Story) -> StoryItem? {
        let idx = currentIndex(for: story)
        guard idx < story.items.count else { return nil }
        return story.items[idx]
    }

    func progress(for index: Int, in story: Story) -> Double {
        let currentIdx = currentIndex(for: story)
        return index < currentIdx ? 1 : index == currentIdx ? 0.3 : 0
    }

    func prepareForNewStory(_ story: Story) {
        if currentStoryIndices[story.id] == nil {
            currentStoryIndices[story.id] = 0
        }
        shouldNavigateToNext = nil
        shouldDismiss = false
    }
}
