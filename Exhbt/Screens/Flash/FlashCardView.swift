//
//  FlashCardView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/06/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import AVFoundation
import SwiftUI

struct FlashCardView: View {
    @State private var translation: CGSize = .zero
    @State private var swipeStatus: LikeDislike = .none

    var model: FlashDisplayModel

    private var onRemove: (_ model: FlashDisplayModel, _ interaction: InteractionResponse) -> Void

    private var thresholdPercentage: CGFloat = 0.4 // when the user has draged 50% the width of the screen in either direction

    private enum LikeDislike: Int {
        case like, dislike, none
    }

    private let colors = [
        Color(uiColor: .logoGradientBlue), Color(uiColor: .logoGradientLightPurple), Color(uiColor: .logoGradientDarkPurple),
    ]

    init(model: FlashDisplayModel, onRemove: @escaping (_ model: FlashDisplayModel, _ interaction: InteractionResponse) -> Void) {
        self.model = model
        self.onRemove = onRemove
    }

//    init(onRemove: @escaping (_ model: FlashDisplayModel) -> Void) {
//        self.onRemove = onRemove
//    }

    /// What percentage of our own width have we swipped
    /// - Parameters:
    ///   - geometry: The geometry
    ///   - gesture: The current gesture translation value
    private func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                ZStack(alignment: self.swipeStatus == .like ? .topLeading : .topTrailing) {
                    if let videoURL = model.videoURL {
                        VideoContainerView(url: videoURL)

                    } else {
                        AsyncImage(url: model.photoURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()

                        } placeholder: {
                            LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom)
                        }
                    }

                    if self.swipeStatus == .like {
                        HStack {
                            Image(systemName: "hand.thumbsup.fill")
                            Text("LIKE")
                        }
                        .font(.headline)
                        .padding()
                        .cornerRadius(10)
                        .foregroundColor(Color.green)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 3.0)
                        ).padding(24)
                        .rotationEffect(Angle.degrees(-45))
                    } else if self.swipeStatus == .dislike {
                        HStack {
                            Image(systemName: "hand.thumbsdown.fill")
                            Text("DISLIKE")
                        }
                        .font(.headline)
                        .padding()
                        .cornerRadius(10)
                        .foregroundColor(Color.red)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 3.0)
                        ).padding(.top, 45)
                        .rotationEffect(Angle.degrees(45))
                    }
                }
            }
            .background(Color.clear)
            .cornerRadius(12)
            .shadow(radius: 7)
            .animation(.interactiveSpring(), value: 2)
            .offset(x: self.translation.width, y: 0)
            .rotationEffect(.degrees(Double(self.translation.width / geometry.size.width) * 25), anchor: .bottom)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.translation = value.translation

                        if (self.getGesturePercentage(geometry, from: value)) >= self.thresholdPercentage {
                            self.swipeStatus = .like
                        } else if self.getGesturePercentage(geometry, from: value) <= -self.thresholdPercentage {
                            self.swipeStatus = .dislike
                        } else {
                            self.swipeStatus = .none
                        }

                    }.onEnded { value in
                        // determine snap distance > 0.5 aka half the width of the screen
                        if abs(self.getGesturePercentage(geometry, from: value)) > self.thresholdPercentage {
                            self.onRemove(self.model, self.swipeStatus == .like ? InteractionResponse.like : InteractionResponse.dislike)

                        } else {
                            self.translation = .zero
                        }
                    }
            )
            .onAppear {
                debugLog("FlashView", "onAppear: \(model.id)")
            }
            .onDisappear {
                debugLog("FlashView", "onDisappear: \(model.id)")
            }
        }
    }
}

struct CreatedDateView: View {
    var date: String

    var body: some View {
        HStack {
            Text("Created date")
                .padding(4)
                .foregroundColor(.white)
                .background(.ultraThinMaterial)
        }
    }
}

struct FlashCardView_Previews: PreviewProvider {
    static var previews: some View {
        FlashCardView(model: FlashDisplayModel(id: 1, index: 0, url: "https://res.cloudinary.com/dwkwx0jor/image/upload/c_fill,h_920/competitions/464.jpg", videUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
                      onRemove: { _, _ in
                          // do nothing
                      })
                      .frame(height: 400)
                      .padding()
    }
}
