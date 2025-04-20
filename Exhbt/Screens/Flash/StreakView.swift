//
//  StreakView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/06/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct StreakView: View {
    private let colors = [
        Color(uiColor: .logoGradientBlue), Color(uiColor: .logoGradientLightPurple), Color(uiColor: .logoGradientDarkPurple),
    ]

    @Binding var streak: Int
    @State var animated = false

    var maxStreak = 5

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                VStack {
                    if streak > 0 {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                                .frame(width: geometry.size.width, height: geometry.size.height)

                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing))
//                                    .animation(.easeInOut, value: animated)
                                    .frame(width: getWidth(geometry: geometry, streak: streak), height: geometry.size.height)

                                Text("\(streak)/\(maxStreak)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
    }

    func getWidth(geometry: GeometryProxy, streak: Int) -> CGFloat {
        geometry.size.width * (0.2 * CGFloat(streak))
    }
}

struct StreakView_Previews: PreviewProvider {
    static var previews: some View {
        StreakView(streak: .constant(1))
            .frame(width: 320, height: 36)
    }
}
