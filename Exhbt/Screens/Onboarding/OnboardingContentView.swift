//
//  OnboardingContentView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 19/08/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct OnboardingContentView: View {
    @State var currentPage = 0
    private var onSkip: (() -> Void)?

    init(onSkip: ( () -> Void)? = nil) {
        self.onSkip = onSkip
    }

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingCardView(index: 0)
                    .tag(0)
                OnboardingCardView(index: 1)
                    .tag(1)
                OnboardingCardView(index: 2)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(20)

            Spacer()

            HStack {
                Button("Skip") {
                    onSkip?()
                }
                .foregroundColor(.gray)

                Spacer()

                Button("Next") {
                    if currentPage == 2 {
                        onSkip?()
                    }
                    currentPage += 1
                }
                .buttonStyle(MainButtonStyle())
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
        }
    }
}

struct OnboardingContentView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContentView()
    }
}
