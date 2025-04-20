//
//  PrizeContentView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/01/2024.
//  Copyright © 2024 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct PrizeContentView: View {
    var prize: PrizeDisplayModel

    var body: some View {
        GeometryReader { geometry in

            VStack {
                Image(uiImage: UIImage(named: prize.medalType.imageName)!)
                HStack(alignment: .center, spacing: 2) {
                    Text(prize.points, format: .number)
                        .font(.title2.bold())
                    Text("points")
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
        }
    }
}

#Preview {
    PrizeContentView(prize: PrizeDisplayModel.sample)
}
