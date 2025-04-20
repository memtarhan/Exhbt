//
//  PointsTotalCountView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 22/06/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct PointsTotalCountView: View {
    private let colors = [
        Color(uiColor: .logoGradientBlue), Color(uiColor: .logoGradientLightPurple), Color(uiColor: .logoGradientDarkPurple),
    ]

    private let lineColors = [
        Color(uiColor: .lineGradientLeftColor), Color(uiColor: .lineGradientRightColor),
    ]

    var count: Int
    var isLoading: Bool

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: lineColors), startPoint: .leading, endPoint: .trailing)
                .frame(height: 3)

            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color(uiColor: .logoGradientDarkPurple))
                        .controlSize(.small)
                }
                Image(uiImage: UIImage(named: "CoinIcon")!)
                Text(count > 1 ? "\(count) coins" : "\(count) coin")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
    }
}

struct StrikeHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PointsTotalCountView(count: 5, isLoading: true)
    }
}
