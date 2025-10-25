//
//  StoryPlayerView.swift
//  Stories
//
//  Created by Arkadiusz Matecki on 25/10/2025.
//

import SwiftUI

struct StoryPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: StoriesViewModel

    let story: Story
    @Binding var navigationPath: NavigationPath

    var body: some View {
        ZStack(alignment: .top) {
            storyImageView

            VStack {
                progressBars
                Spacer()
                likeButton
            }
            .padding()
        }

        .background(Style.Colors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.prepareForNewStory(story)
            viewModel.markSeen(story)
        }
        .onReceive(viewModel.$shouldNavigateToNext) { nextStory in
            guard let nextStory = nextStory else { return }
            navigationPath.append(nextStory)
            viewModel.cleanupAfterNavigation()
        }
        .onReceive(viewModel.$shouldDismiss) { shouldDismiss in
            guard shouldDismiss else { return }
            navigationPath = NavigationPath()
            viewModel.cleanupAfterDismiss()
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.height > 100 {
                        viewModel.handleSwipeDown()
                    }
                }
        )
        .onTapGesture { location in
            let screenWidth = UIScreen.main.bounds.size.width
            if location.x < screenWidth / 2 {
                viewModel.previous(in: story)
            } else {
                viewModel.next(in: story)
            }
        }
    }

    @ViewBuilder
    private var storyImageView: some View {
        if let item = viewModel.currentItem(in: story),
           let url = viewModel.photoURL(for: item)
        {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
    }

    private var progressBars: some View {
        HStack(spacing: 4) {
            ForEach(0 ..< story.items.count, id: \.self) { index in
                ProgressView(value: viewModel.progress(for: index, in: story))
                    .progressViewStyle(.linear)
                    .tint(Style.Colors.text)
            }
        }
    }

    @ViewBuilder
    private var likeButton: some View {
        if let item = viewModel.currentItem(in: story) {
            Button {
                viewModel.toggleLike(item)
            } label: {
                Image(systemName: viewModel.isLiked(item) ? "heart.fill" : "heart")
                    .foregroundColor(Style.Colors.text)
                    .font(Style.Fonts.heart)
                    .padding()
            }
        }
    }
}
