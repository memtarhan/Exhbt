//
//  FlashSwipeResultView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 22/06/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

enum FlashInteractResult: Int {
    case win
    case lose

    var title: String {
        switch self {
        case .win:
            return "You've won!".uppercased()
        case .lose:
            return "You've lost!".uppercased()
        }
    }

    var colors: [Color] {
        switch self {
        case .win:
            return [Color.green.opacity(0.5), Color.green]
        case .lose:
            return [Color.red.opacity(0.5), Color.red]
        }
    }

    init?(fromResponse response: FlashInteractResultResponse) {
        switch response {
        case .win:
            self = .win
        case .lose:
            self = .lose
        }
    }
}

struct FlashSwipeResultView: View {
    var result: FlashInteractResult
    @State var isAnimated: Bool = false

    var animation: Animation {
        Animation.easeInOut(duration: 1.5).repeatCount(2)
    }

    var body: some View {
        VStack {
            Text(result.title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .overlay {
                    LinearGradient(
                        colors: result.colors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Text(result.title)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    )
                }
//                .padding(.horizontal, 20)
//                .padding(.vertical, 8)
//                .background(.ultraThinMaterial)
//                .clipShape(Capsule())
//                .animation(animation, value: isAnimated)
        }
        .onAppear {
            self.isAnimated = true
        }
    }
}

struct FlashSwipeResultView_Previews: PreviewProvider {
    static var previews: some View {
        FlashSwipeResultView(result: .lose)
    }
}
