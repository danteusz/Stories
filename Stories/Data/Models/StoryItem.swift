//
//  StoryItem.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import Foundation

struct StoryItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let seed: String
    let duration: Double
}
