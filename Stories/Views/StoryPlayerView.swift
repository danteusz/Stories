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
    @State private var isPaused = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let item = viewModel.currentItem(in: story),
               let url = viewModel.photoURL(for: item)
            {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }

            VStack {
                HStack(spacing: 4) {
                    ForEach(0 ..< story.items.count, id: \.self) { idx in
                        ProgressView(value: viewModel.progress(for: idx))
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
        .onAppear { viewModel.markSeen(story) }
        .navigationBarBackButtonHidden(true)
        .gesture(DragGesture(minimumDistance: 20)
            .onEnded { value in
                if value.translation.height > 100 {
                    dismiss()
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
