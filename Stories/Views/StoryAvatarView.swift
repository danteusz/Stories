//
//  StoryAvatarView.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import SwiftUI

struct StoryAvatarView: View {
    let story: Story
    let isSeen: Bool
    let avatarUrl: URL?

    var body: some View {
        VStack {
            Circle()
                .strokeBorder(
                    isSeen ? Style.Colors.seenBorder : Style.Colors.unseenBorder,
                    lineWidth: Style.Sizes.storyBorder
                )
                .background(Circle().fill(Color.white))
                .frame(
                    width: Style.Sizes.storyCircle,
                    height: Style.Sizes.storyCircle
                )
                .overlay(
                    AsyncImage(url: avatarUrl) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(
                        width: Style.Sizes.avatarSize,
                        height: Style.Sizes.avatarSize
                    )
                    .clipShape(Circle())
                )
            Text(story.author)
                .font(Style.Fonts.author)
                .foregroundColor(.primary)
        }
    }
}
