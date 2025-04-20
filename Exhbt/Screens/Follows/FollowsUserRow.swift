//
//  FollowsUserRow.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 06/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct FollowsUserRow: View {
    var user: FollowDisplayModel

    var body: some View {
        HStack {
            AsyncImage(url: user.photoURL) { image in
                image.resizable()
            } placeholder: {
                Color.blue
            }

            .frame(width: 48, height: 48)
            .clipShape(Circle())

            Text(user.username)

            Spacer()

            Button("Follow") {
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
    }
}

struct FollowsUserRow_Previews: PreviewProvider {
    static var previews: some View {
        FollowsUserRow(user: FollowDisplayModel.sample)
    }
}
