//
//  StoriesViewModel.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import Combine
import SwiftUI

@MainActor
final class StoriesViewModel: ObservableObject {
    @Published private(set) var stories: [Story] = []
    @Published private(set) var seen: Set<String>
    @Published private(set) var liked: Set<String>
    @Published var currentStoryIndices: [String: Int] = [:]
    @Published var storyProgress: [String: Double] = [:]
    @Published var shouldNavigateToNext: Story?
    @Published var shouldDismiss = false
    @Published var isPaused = false

    let navigationTitle = "Stories"

    private let persistence: StoriesPersistenceProtocol
    private let dataSource: StoryDataSourceProtocol
    private var timer: Timer?
    private var currentStoryId: String?

    init(dataSource: StoryDataSourceProtocol = StoryDataSource(),
         persistence: StoriesPersistenceProtocol = StoriesPersistence()) {
        self.dataSource = dataSource
        self.persistence = persistence
        stories = dataSource.loadStories()
        seen = persistence.loadSeen()
        liked = persistence.loadLiked()
    }

    func markSeen(_ story: Story) {
        seen.insert(story.id)
        persistence.saveSeen(seen)
    }

    func isSeen(_ story: Story) -> Bool {
        seen.contains(story.id)
    }

    func prepareForNewStory(_ story: Story) {
        stopTimer()
        currentStoryId = story.id

        if currentStoryIndices[story.id] == nil {
            currentStoryIndices[story.id] = 0
        }

        if storyProgress[story.id] == nil {
            storyProgress[story.id] = 0.0
        }

        shouldNavigateToNext = nil
        shouldDismiss = false

        startTimer(for: story)
    }

    private func startTimer(for story: Story) {
        guard let item = currentItem(in: story) else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self = self, !self.isPaused else { return }

                let currentProgress = self.storyProgress[story.id] ?? 0.0
                let increment = 0.05 / item.duration
                let newProgress = min(currentProgress + increment, 1.0)

                self.storyProgress[story.id] = newProgress

                if newProgress >= 1.0 {
                    self.autoAdvanceToNext(in: story)
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func autoAdvanceToNext(in story: Story) {
        stopTimer()
        storyProgress[story.id] = 0.0
        next(in: story)
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

    func photoURL(for item: StoryItem) -> URL? {
        let width = Int(UIScreen.main.bounds.size.width * UIScreen.main.scale)
        let height = Int(UIScreen.main.bounds.size.height * UIScreen.main.scale)
        return URL(string: "https://picsum.photos/seed/\(item.seed)/\(width)/\(height)")
    }

    func avatarUrl(for story: Story) -> URL? {
        let size = Int(Style.Sizes.avatarSize * UIScreen.main.scale)
        return URL(string: "https://picsum.photos/seed/\(story.id)/\(size)")
    }

    func currentIndex(for story: Story) -> Int {
        currentStoryIndices[story.id] ?? 0
    }

    func currentItem(in story: Story) -> StoryItem? {
        let index = currentIndex(for: story)
        guard index < story.items.count else { return nil }
        return story.items[index]
    }

    func progress(for index: Int, in story: Story) -> Double {
        let currentIndex = currentIndex(for: story)

        if index < currentIndex {
            return 1.0
        } else if index == currentIndex {
            return storyProgress[story.id] ?? 0.0
        } else {
            return 0.0
        }
    }

    func next(in story: Story) {
        let currentIndex = currentIndex(for: story)

        resetStoryProgress(for: story)
        isPaused = false

        if currentIndex < story.items.count - 1 {
            moveToItem(at: currentIndex + 1, in: story)
            return
        }
        navigateToAdjacentStory(from: story, direction: .next)
    }

    func previous(in story: Story) {
        let currentIndex = currentIndex(for: story)

        resetStoryProgress(for: story)

        isPaused = false

        if currentIndex > 0 {
            moveToItem(at: currentIndex - 1, in: story)
            return
        }

        navigateToAdjacentStory(from: story, direction: .previous)
    }

    private enum NavigationDirection {
        case next, previous
    }

    private func resetStoryProgress(for story: Story) {
        stopTimer()
        storyProgress[story.id] = 0.0
    }

    private func moveToItem(at index: Int, in story: Story) {
        currentStoryIndices[story.id] = index
        startTimer(for: story)
    }

    private func navigateToAdjacentStory(from story: Story, direction: NavigationDirection) {
        guard let currentStoryIndex = stories.firstIndex(where: { $0.id == story.id }) else {
            return
        }

        let targetIndex = direction == .next ? currentStoryIndex + 1 : currentStoryIndex - 1

        switch direction {
        case .next:
            if targetIndex < stories.count {
                navigateToStory(at: targetIndex, startAtIndex: 0)
            } else {
                shouldDismiss = true
            }
        case .previous:
            if targetIndex >= 0 {
                let previousStory = stories[targetIndex]
                navigateToStory(at: targetIndex, startAtIndex: previousStory.items.count - 1)
            } else {
                shouldDismiss = true
            }
        }
    }

    private func navigateToStory(at index: Int, startAtIndex itemIndex: Int) {
        let targetStory = stories[index]
        currentStoryIndices[targetStory.id] = itemIndex
        storyProgress[targetStory.id] = 0.0
        shouldNavigateToNext = targetStory
    }

    func handleSwipeDown() {
        shouldDismiss = true
    }

    func cleanupAfterNavigation() {
        shouldNavigateToNext = nil
    }

    func cleanupAfterDismiss() {
        currentStoryIndices = [:]
        storyProgress = [:]
        stopTimer()
        shouldDismiss = false
        isPaused = false
    }

    deinit {
        MainActor.assumeIsolated {
            stopTimer()
        }
    }
}
