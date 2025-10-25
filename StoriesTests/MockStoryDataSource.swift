//
//  MockStoryDataSource.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//


@testable import Stories

// Conforms to the protocol defined above
final class MockStoryDataSource: StoryDataSourceProtocol {
    var mockStories: [Story]

    init(stories: [Story] = []) {
        self.mockStories = stories
    }

    func loadStories() -> [Story] {
        return mockStories
    }
}
