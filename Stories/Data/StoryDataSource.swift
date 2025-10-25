//
//  StoryDataSource.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import Foundation

protocol StoryDataSourceProtocol {
    func loadStories() -> [Story]
}


final class StoryDataSource: StoryDataSourceProtocol {
    func loadStories() -> [Story] {
        if let stories = loadFromBundle() {
            return stories
        } else {
            return []
        }
    }

    private func loadFromBundle() -> [Story]? {
        guard let url = Bundle.main.url(forResource: "stories", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([Story].self, from: data)
    }

}
