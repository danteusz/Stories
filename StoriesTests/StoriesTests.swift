//
//  StoriesTests.swift
//  StoriesTests
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import Testing

@testable import Stories

struct TestData {
    static let storyItem1 = StoryItem(id: "aaa", title: "Item 1", seed: "s1", duration: 5)
    static let storyItem2 = StoryItem(id: "bbb", title: "Item 2", seed: "s2", duration: 5)
    static let storyItem3 = StoryItem(id: "ccc", title: "Item 3", seed: "s3", duration: 5)

    static let story1 = Story(id: "aaa", author: "Author A", items: [storyItem1, storyItem2])
    static let story2 = Story(id: "bbb", author: "Author B", items: [storyItem3])

    static let mockStories = [story1, story2]
}

@MainActor
struct StoriesViewModelTests {

    var sut: StoriesViewModel
    var mockDataSource: MockStoryDataSource
    var mockPersistence: MockStoriesPersistence

    init() {
        mockDataSource = MockStoryDataSource(stories: TestData.mockStories)
        mockPersistence = MockStoriesPersistence()

        mockPersistence.seenSet.insert(TestData.story2.id)

        sut = StoriesViewModel(dataSource: mockDataSource, persistence: mockPersistence)
    }

    @Test("Initialization loads stories and persistence state correctly")
    func initialization_loadsStoriesAndPersistenceState() {
            
        #expect(self.sut.stories.count == 2)
        #expect(self.sut.stories.first?.author == "Author A")

        #expect(self.sut.seen.contains(TestData.story2.id))
        #expect(!self.sut.seen.contains(TestData.story1.id))
    }

    @Test("markSeen adds story to seen set and calls save on persistence")
    func markSeen_addsStoryToSeenSetAndSaves() {
            
        let storyToMark = TestData.story1
        #expect(!self.sut.seen.contains(storyToMark.id), "Pre-condition: Story must not be seen.")

            
        self.sut.markSeen(storyToMark)

        #expect(self.sut.seen.contains(storyToMark.id), "Story should be marked as seen in ViewModel.")
        #expect(self.mockPersistence.seenSet.contains(storyToMark.id), "Story should be marked as seen in Mock Persistence.")
        #expect(self.mockPersistence.saveSeenCallCount == 1, "Save method should be called once.")
    }

    @Test("isSeen returns the correct status")
    func isSeen_returnsCorrectState() {

        #expect(self.sut.isSeen(TestData.story2) == true)
        #expect(self.sut.isSeen(TestData.story1) == false)
    }

    func prepareStory(_ story: Story) {
        self.sut.prepareForNewStory(story)
    }

    @Test("prepareForNewStory initializes current item index and progress")
    func prepareForNewStory_initializesIndexAndProgress() {
            
        let story = TestData.story1

            
        prepareStory(story)

            
        #expect(self.sut.currentStoryIndices[story.id] == 0)
        #expect(self.sut.storyProgress[story.id] == 0.0)
    }

    @Test("handleTapForward moves to the next item in the same story")
    func handleTapForward_movesToNextItem() {
            
        let story = TestData.story1
        prepareStory(story)
        #expect(self.sut.currentStoryIndices[story.id] == 0)

            
        self.sut.next(in: story)

            
        #expect(self.sut.currentStoryIndices[story.id] == 1, "Should advance to the next story item (index 1).")
        #expect(self.sut.storyProgress[story.id] == 0.0, "Progress should reset for the new item.")
    }

    @Test("handleTapBackward moves to the previous item in the same story")
    func handleTapBackward_movesToPreviousItem() {
            
        let story = TestData.story1
        prepareStory(story)
        self.sut.currentStoryIndices[story.id] = 1

            
        self.sut.previous(in: story)

            
        #expect(self.sut.currentStoryIndices[story.id] == 0, "Should move back to the previous story item (index 0).")
        #expect(self.sut.storyProgress[story.id] == 0.0, "Progress should reset for the new item.")
    }

    @Test("handleTapForward at last item of a story navigates to the next story")
    func handleTapForward_atLastItem_navigatesToNextStory() {
            
        let currentStory = TestData.story1
        let nextStory = TestData.story2
        prepareStory(currentStory)

        self.sut.currentStoryIndices[currentStory.id] = currentStory.items.count - 1
        #expect(self.sut.shouldNavigateToNext == nil)

            
        self.sut.next(in: currentStory)

            
        #expect(self.sut.shouldNavigateToNext?.id == nextStory.id, "Should trigger navigation to the next story.")
    }

    @Test("handleTapBackward at first item of a story navigates to the previous story's last item")
    func handleTapBackward_atFirstItem_navigatesToPreviousStoryLastItem() {
            
        let previousStory = TestData.story1
        let currentStory = TestData.story2

        prepareStory(currentStory)
        self.sut.currentStoryIndices[currentStory.id] = 0
        #expect(self.sut.shouldNavigateToNext == nil)

            
        self.sut.previous(in: currentStory)

            
        #expect(self.sut.shouldNavigateToNext?.id == previousStory.id, "Should trigger navigation to the previous story.")
        #expect(self.sut.currentStoryIndices[previousStory.id] == previousStory.items.count - 1, "Previous story's index should be set to its last item.")
    }

    @Test("handleTapForward at last item of the last story dismisses")
    func handleTapForward_atLastStoryLastItem_dismisses() {
            
        let lastStory = TestData.story2
        prepareStory(lastStory)
        self.sut.currentStoryIndices[lastStory.id] = lastStory.items.count - 1
        #expect(self.sut.shouldDismiss == false)

            
        self.sut.next(in: lastStory)

            
        #expect(self.sut.shouldDismiss == true, "Should set the dismiss flag when finishing the last story.")
    }

    @Test("handleTapBackward at first item of the first story does nothing")
    func handleTapBackward_atFirstStoryFirstItem_doesNothing() {
            
        let firstStory = TestData.story1
        prepareStory(firstStory)
        self.sut.currentStoryIndices[firstStory.id] = 0 // Current is Item 0

            
        self.sut.previous(in: firstStory)

            
        #expect(self.sut.shouldNavigateToNext == nil, "Should not navigate since there is no previous story.")
        #expect(self.sut.currentStoryIndices[firstStory.id] == 0, "Index should remain at 0.")
    }

    @Test("handleSwipeDown sets the dismiss flag")
    func handleSwipeDown_setsDismissFlag() {
            
        #expect(self.sut.shouldDismiss == false)

            
        self.sut.handleSwipeDown()

            
        #expect(self.sut.shouldDismiss == true)
    }

    @Test("cleanupAfterDismiss resets all state properties")
    func cleanupAfterDismiss_resetsState() {
            
        let story = TestData.story1
        prepareStory(story)
        self.sut.shouldDismiss = true
        self.sut.isPaused = true
        self.sut.currentStoryIndices[story.id] = 1
        self.sut.storyProgress[story.id] = 0.5

            
        self.sut.cleanupAfterDismiss()

            
        #expect(self.sut.currentStoryIndices.isEmpty)
        #expect(self.sut.storyProgress.isEmpty)
        #expect(self.sut.shouldDismiss == false)
        #expect(self.sut.isPaused == false)
    }
}
