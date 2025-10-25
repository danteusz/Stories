//
//  Story.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import Foundation

struct Story: Identifiable, Codable, Hashable {
    let id: UUID
    let author: String
    let items: [StoryItem]
}
