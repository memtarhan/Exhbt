//
//  FlashView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/06/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import AVFoundation
import SwiftUI

struct FlashView: View {
    @ObservedObject var model = FlashModel()

    @State var streak: Int = 0
    @State private var shouldShowResult = false

    /// Return the CardViews width for the given offset in the array
    /// - Parameters:
    ///   - geometry: The geometry proxy of the parent
    ///   - id: The ID of the current model
    private func getCardWidth(_ geometry: GeometryProxy, index: Int) -> CGFloat {
        let offset: CGFloat = CGFloat(model.displayModels.count - 1 - index) * 10
        return geometry.size.width - offset
    }

    /// Return the CardViews frame offset for the given offset in the array
    /// - Parameters:
    ///   - geometry: The geometry proxy of the parent
    ///   - id: The ID of the current model
    private func getCardOffset(_ geometry: GeometryProxy, index: Int) -> CGFloat {
        return CGFloat(model.displayModels.count - 1 - index) * 15
    }

    private var maxID: Int {
        return model.displayModels.map { $0.index }.max() ?? 0
    }

    private let gradient = AngularGradient(
        gradient: Gradient(colors: [Color.blue, .white]),
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(330)
    )

    @State private var shouldAnimate = true

    var body: some View {
        VStack {
            if model.isLoading {
                Circle()
                    .trim(from: 0.0, to: 0.9)
                    .stroke(gradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(Angle(degrees: shouldAnimate ? 0 : 360))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                            shouldAnimate.toggle()
                        }

                    }.frame(width: 45, height: 45)

            } else {
                VStack(spacing: 12) {
                    PointsTotalCountView(count: model.coinsCount, isLoading: model.isLoadingCoinsCount)
                    Spacer()
                    if model.displayModels.isEmpty {
                        Text("We don't have any more Competitions.\nCheck back with us later.")
                            .font(.headline)
                            .multilineTextAlignment(.center)

                    } else {
                        GeometryReader { geometry in
                            VStack(alignment: .leading, spacing: 8) {
                                ZStack(alignment: .center) {
                                    ForEach(model.displayModels) { displayModel in
                                        // Range Operator
                                        if (self.maxID - 3) ... self.maxID ~= displayModel.index {
                                            FlashCardView(model: displayModel, onRemove: { removedModel, interaction in
                                                // Remove that model from our array
                                                self.model.displayModels.removeAll { $0.id == removedModel.id }
                                                self.streak += 1

                                                self.model.interact(removedModel, interaction: interaction)
                                                self.shouldShowResult = true

                                                if self.streak == 5 {
                                                    self.streak = 0
                                                    self.model.loadMore()
                                                }
                                            })
                                            .animation(.spring(), value: 1)
                                            .frame(width: self.getCardWidth(geometry, index: displayModel.index), height: geometry.size.height * 0.9)
                                            .offset(x: 0, y: self.getCardOffset(geometry, index: displayModel.index))
                                        }
                                    }
                                }

                                Spacer()

//                                StreakView(streak: $streak)
//                                    .frame(height: geometry.size.height / 24)
//
//                                if streak == 5 {
//                                    Text("You have won 5 in a row")
//                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    if let result = model.result {
                        FlashSwipeResultView(result: result)
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .onAppear {
            model.load()
        }
    }
}

struct FlashView_Previews: PreviewProvider {
    static var previews: some View {
        FlashView()
    }
}
