//
//  Style.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import SwiftUI

enum Style {
    enum Colors {
        static let unseenBorder = LinearGradient(
            colors: [Color.blue, Color.purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let seenBorder = LinearGradient(
            colors: [Color.white, Color.gray],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let background = Color.black
        static let text = Color.white
        static let unreadDot = Color.blue
    }

    enum Fonts {
        static let author = Font.caption
        static let initial = Font.title
        static let heart = Font.largeTitle
    }

    enum Sizes {
        static let storyCircle: CGFloat = 100
        static let storyBorder: CGFloat = 5
        static let avatarSize = storyCircle - storyBorder - 10
        static let unreadDot: CGFloat = 12
        static let padding: CGFloat = 16
    }
}
