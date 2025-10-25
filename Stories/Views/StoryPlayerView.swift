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
    @State private var isPaused = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let item = viewModel.currentItem(in: story),
               let url = viewModel.photoURL(for: item)
            {
                AsyncImage(url: url) {
                    image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }

            VStack {
                HStack(spacing: 4) {
                    ForEach(0 ..< story.items.count, id: \.self) {
                        index in
                        ProgressView(value: viewModel.progress(for: index, in: story))
                            .progressViewStyle(.linear)
                            .tint(Style.Colors.text)
                    }
                }
                .padding()

                Spacer()

                if let item = viewModel.currentItem(in: story) {
                    Button(action: { viewModel.toggleLike(item) }) {
                        Image(systemName: viewModel.isLiked(item) ? "heart.fill" : "heart")
                            .foregroundColor(Style.Colors.text)
                            .font(Style.Fonts.heart)
                            .padding()
                    }
                }
            }
        }
        .background(Style.Colors.background.ignoresSafeArea())
        .onAppear {
            viewModel.prepareForNewStory(story)
            viewModel.markSeen(story)
        }
        .onReceive(viewModel.$shouldNavigateToNext) { nextStory in
            if let nextStory = nextStory {
                navigationPath.append(nextStory)
                viewModel.shouldNavigateToNext = nil
            }
        }
        .onReceive(viewModel.$shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                navigationPath = NavigationPath()
                viewModel.shouldDismiss = false
            }
        }
        .navigationBarBackButtonHidden(true)
        .gesture(DragGesture(minimumDistance: 20)
            .onEnded { value in
                if value.translation.height > 100 {
                    viewModel.shouldDismiss = true
                }
            })
        .onTapGesture { location in
            let screenWidth = UIScreen.main.bounds.width
            if location.x < screenWidth / 2 {
                viewModel.previous(in: story)
            } else {
                viewModel.next(in: story)
            }
        }
    }
}
