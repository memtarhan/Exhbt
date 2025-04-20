//
//  NotificationRow.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 14/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct NotificationRow: View {
    let data: NotificationDisplayModel

    var body: some View {
        HStack {
            AsyncImage(url: data.photoURL) { image in
                image.resizable()
            } placeholder: {
                VStack {
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.gray, lineWidth: 1.5))
            }

            .frame(width: 48, height: 48)
            .cornerRadius(data.cornerRadius)

            VStack(alignment: .leading) {
                Text(data.text)
                    .font(.system(size: 13))
                Text(data.date)
                    .font(.caption2)
            }
        }
        .padding(8)
    }
}

struct NotificationRow_Previews: PreviewProvider {
    static var previews: some View {
        NotificationRow(data: NotificationDisplayModel.sample)
    }
}
