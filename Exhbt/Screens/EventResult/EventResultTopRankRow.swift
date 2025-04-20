//
//  EventResultTopRankRow.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import SwiftUI

struct EventResultTopRankColumn: View {
    var data: ExhbtResultTopRankUserDisplayModel
    var imageHeight: CGFloat

    var body: some View {
        VStack(spacing: 12) {
            VStack {
                AsyncImage(url: URL(string: data.photoURL ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    Color.blue
                }

                .frame(width: imageHeight, height: imageHeight)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color(uiColor: UIColor(named: data.rankType.colorName) ?? .black), lineWidth: 2)
                }

                Text(data.username ?? "@-")
                    .lineLimit(1)
                    .font(.system(size: 10, weight: .light))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .padding(8)
                    .background(Color.white.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(spacing: 0) {
                Text(data.score)
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Text(data.rankType.displayNumber ?? "")
                    .font(.title2.bold())
                    .padding(10)
                    .background(Color(uiColor: UIColor(named: data.rankType.colorName) ?? .black))
                    .clipShape(Circle())
            }
        }
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct EventResultTopRanksRow: View {
    var data: [ExhbtResultTopRankUserDisplayModel]
    var onSelection: ((_ userId: Int) -> Void)?

    var body: some View {
        // TODO: Make VStack dynamic
        HStack(alignment: .bottom) {
            if data.count > 1 {
                EventResultTopRankColumn(data: data[1], imageHeight: 56)
                    .onTapGesture {
                        onSelection?(data[1].id)
                    }
            }

            if data.count > 0 {
                EventResultTopRankColumn(data: data[0], imageHeight: 120)
                    .onTapGesture {
                        onSelection?(data[0].id)
                    }
            }

            if data.count > 2 {
                EventResultTopRankColumn(data: data[2], imageHeight: 56)
                    .onTapGesture {
                        onSelection?(data[2].id)
                    }
            }
        }
        .background(Color.clear)
    }
}

struct EventResultTopRanksRow_Previews: PreviewProvider {
    static var previews: some View {
        EventResultTopRanksRow(data: ExhbtResultTopRanksDisplayModel.sample.users)
    }
}
