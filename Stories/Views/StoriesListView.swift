//
//  StoriesListView.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import SwiftUI

struct StoriesListView: View {
    @StateObject private var viewModel = StoriesViewModel()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                LazyHStack(spacing: Style.Sizes.padding) {
                    ForEach(viewModel.stories) {
                        story in
                        Button {
                            navigationPath.append(story)
                        } label: {
                            StoryAvatarView(
                                story: story,
                                isSeen: viewModel.isSeen(story),
                                avatarUrl: viewModel.avatarUrl(for: story)
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationDestination(for: Story.self) { story in
                StoryPlayerView(story: story, navigationPath: $navigationPath)
                    .environmentObject(viewModel)
            }
        }
    }
}

// MARK: - Helpers

// MARK: - Preview

struct StoriesAppView: View {
    var body: some View {
        StoriesListView()
    }
}

#Preview {
    StoriesAppView()
}
