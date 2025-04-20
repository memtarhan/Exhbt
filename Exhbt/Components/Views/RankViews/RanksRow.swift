//
//  RanksRow.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 31/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct RanksRow: View {
    var data: ExhbtResultTopRanksDisplayModel
    var onSelection: ((_ userId: Int) -> Void)?

    var body: some View {
        // TODO: Make VStack dynamic
        HStack(alignment: .center) {
            VStack {
                Spacer()
                RankColumn(data: data.users[1])
                    .onTapGesture {
                        onSelection?(data.users[1].id)
                    }
            }

            VStack {
                RankColumn(data: data.users[0])
                    .onTapGesture {
                        onSelection?(data.users[0].id)
                    }
                Spacer()
            }

            if data.users.count > 2 {
                VStack {
                    Spacer(minLength: 40)
                    RankColumn(data: data.users[2])
                        .onTapGesture {
                            onSelection?(data.users[2].id)
                        }
                }
            }
        }
    }
}

struct RanksRow_Previews: PreviewProvider {
    static var previews: some View {
        RanksRow(data: ExhbtResultTopRanksDisplayModel.sample)
    }
}
