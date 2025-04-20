//
//  RankColumn.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 31/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct RankColumn: View {
    var data: ExhbtResultTopRankUserDisplayModel

    var body: some View {
        VStack(spacing: 12) {
            VStack {
                AsyncImage(url: URL(string: data.photoURL ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    Color.blue
                }

                .frame(width: 64, height: 64)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color(uiColor: UIColor(named: data.rankType.colorName) ?? .black), lineWidth: 2)
                }

                Text(data.username ?? "@-")
                    .lineLimit(2)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 0) {
                Text(data.rankType.displayNumber ?? "")
                    .font(.title2.bold())
                    .padding(10)
                    .background(Color(uiColor: UIColor(named: data.rankType.colorName) ?? .black))
                    .clipShape(Circle())
                
                Text(data.score)
                    .font(.title3.bold())
                    .foregroundColor(Color(uiColor: UIColor(named: data.rankType.colorName) ?? .black))
            }
        }
        .padding()
        .background((Color(uiColor: UIColor(named: data.rankType.colorName) ?? .black)).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct RankColumn_Previews: PreviewProvider {
    static var previews: some View {
        RankColumn(data: ExhbtResultTopRankUserDisplayModel.sample)
    }
}
