//
//  PostView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

@MainActor
class PostModel: ObservableObject {
    var image: UIImage?
    var imageURL: String?
    var videoURL: URL?
    @Published var likesCount = 0
    @Published var dislikesCount = 0
    @Published var interaction: PostInteractionType?
    var aspectRatio: Double = 1
    let isOwn: Bool

    private let post: PostDisplayModel

    init(post: PostDisplayModel) {
        self.post = post
        image = post.image
        imageURL = post.imageURL
        videoURL = post.videoURL
        likesCount = post.likesCount
        dislikesCount = post.dislikesCount
        interaction = post.interaction
        aspectRatio = post.aspectRatio
        isOwn = post.isOwn
    }

    func like(currentInteraction: PostInteractionType?) {
        if let interaction = currentInteraction {
            if interaction == .dislike {
                /// - Like
                self.interaction = .like
                likesCount += 1
                dislikesCount -= 1

                sendLikedNotification()
            }

        } else {
            interaction = .like
            likesCount += 1

            sendLikedNotification()
        }
    }

    func dislike(currentInteraction: PostInteractionType?) {
        if let interaction = currentInteraction {
            if interaction == .like {
                /// - Like
                self.interaction = .dislike
                likesCount -= 1
                dislikesCount += 1

                sendDislikedNotification()
            }

        } else {
            interaction = .dislike
            dislikesCount += 1

            sendDislikedNotification()
        }
    }

    private func sendLikedNotification() {
        NotificationCenter.default.post(name: .newPostLikeAvailableNotification, object: nil, userInfo: ["postId": post.id])
    }

    private func sendDislikedNotification() {
        NotificationCenter.default.post(name: .newPostDislikeAvailableNotification, object: nil, userInfo: ["postId": post.id])
    }
}

struct PostView: View {
    private var onDelete: (() -> Void)?

    @ObservedObject private var model: PostModel

    @State private var show = false

    init(post: PostDisplayModel, onDelete: (() -> Void)?) {
        model = PostModel(post: post)
        self.onDelete = onDelete
        show = show
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                PostContentView(model: model, width: geometry.size.width, displayInteractions: $show, onDelete: onDelete)
                if show {
                    PostInteractionView(model: model)
                    Divider()
                }
            }
            .cardBackground()
        }
    }
}

private struct PostContentView: View {
    @ObservedObject var model: PostModel
    var width: CGFloat
    @Binding var displayInteractions: Bool
    
    var onDelete: (() -> Void)?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                if let videoURL = model.videoURL {
                    SimpleVideoContainerView(url: videoURL)
                        .clipped()
                        .onAppear {
                            displayInteractions = true
                        }

                } else if let imageURL = model.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .onAppear {
                                displayInteractions = true
                            }

                    } placeholder: {
                    }

                } else if let image = model.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .onAppear {
                            displayInteractions = true
                        }
                }
            }
            .frame(width: width, height: width * model.aspectRatio)

            if model.isOwn {
                Button {
                    onDelete?()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .tint(Color.white.opacity(0.7))
                }
                .padding()
            }
        }
    }
}

private struct PostInteractionView: View {
    @ObservedObject var model: PostModel

    var body: some View {
        HStack(spacing: 12) {
            if let interaction = model.interaction {
                Button {
                    model.like(currentInteraction: interaction)

                } label: {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(systemName: interaction == .like ? "hand.thumbsup.fill" : "hand.thumbsup")
                        Text("\(model.likesCount)")
                    }
                    .foregroundStyle(Color.blue)
                }

                Button {
                    model.dislike(currentInteraction: interaction)

                } label: {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(systemName: interaction == .dislike ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        Text("\(model.dislikesCount)")
                    }
                    .foregroundStyle(Color.blue)
                }

                Spacer()

            } else {
                Button {
                    model.like(currentInteraction: nil)

                } label: {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(systemName: "hand.thumbsup")
                        Text("\(model.likesCount)")
                    }
                    .foregroundStyle(Color.blue)
                }

                Button {
                    model.dislike(currentInteraction: nil)

                } label: {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(systemName: "hand.thumbsdown")
                        Text("\(model.dislikesCount)")
                    }
                    .foregroundStyle(Color.blue)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

#Preview {
    PostView(post: PostDisplayModel.sample, onDelete: nil)
}
