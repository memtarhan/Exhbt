//
//  OnboardingCardView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 19/08/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import AVFoundation
import SwiftUI

let buttonColors = [
    Color(uiColor: UIColor.blueGradientButtonLeftColor),
    Color(uiColor: UIColor.blueGradientButtonMiddleColor),
    Color(uiColor: UIColor.blueGradientButtonRightColor),
]

struct OnboardingCardView: View {
    var player: AVPlayer?
    private var index = 0
    private var url: URL?

    init(index: Int) {
        self.index = index

        // TODO: Update it to match system´ dark mode or light mode
        if let url = Bundle.main.url(forResource: "video_\(index)_light", withExtension: "MOV") {
            self.url = url
        }
    }

    var body: some View {
        GeometryReader { geometry in

            ZStack {
                VStack(alignment: .center) {
                    if let url {
                        VideoContainerView(showControls: false, url: url)
                            .padding()
                            .frame(height: geometry.size.height / 2)
                    }

                    Spacer()

                    Image(uiImage: UIImage(named: "Screen-Onboarding-Text-\(index)")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: geometry.size.height / 2)
                }
            }
            .padding()
//            .background(LinearGradient(gradient: Gradient(colors: [.yellow.opacity(0.1), .yellow]), startPoint: .top, endPoint: .bottom))
        }
    }
}

struct MainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding([.leading, .trailing], 32)
            .padding([.top, .bottom], 12)
            .background(
                LinearGradient(gradient: Gradient(colors: buttonColors), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .font(.headline)
    }
}

struct OnboardingCardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCardView(index: 0)
    }
}
