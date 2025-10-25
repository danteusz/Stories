    //
    //  StoriesListView.swift
    //  Stories
    //
    //  Created by Arkadiusz Matecki on 25/10/2025.
    //

import SwiftUI

struct StoriesListView: View {
    @StateObject private var viewModel = StoriesViewModel()

    var body: some View {
        NavigationView {
            ScrollView(
                .horizontal,
                showsIndicators: false) {
                LazyHStack(spacing: Style.Sizes.padding) {
                    ForEach(viewModel.stories) {
                        story in
                        NavigationLink(
                            destination: StoryPlayerView(story: story)
                                .environmentObject(viewModel)) {
                            StoryAvatarView(
                                story: story,
                                isSeen: viewModel.isSeen(story),
                                avatarUrl: viewModel.avatarUrl(for: story)
                            )
                            .onAppear {
                                if story == viewModel.stories.last {
                                    viewModel.loadMore()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.navigationTitle)
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
