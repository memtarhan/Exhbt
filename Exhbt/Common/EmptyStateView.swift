//
//  EmptyStateView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 15/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct EmptyStateView: View {
    var title: String
    var subtitle: String? = nil
    var imageName: String? = nil

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                Text(title)
                    .font(.title2.bold())

                if let subtitle {
                    Text(subtitle)
                        .font(.headline)
                }
            }
            .padding()

            if let imageName {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)
                    .opacity(0.25)
                    .foregroundColor(Color.gray)
            }
        }
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(title: "No content available",
                       subtitle: "Check back with us later",
                       imageName: "hand.thumbsup.fill")
    }
}
