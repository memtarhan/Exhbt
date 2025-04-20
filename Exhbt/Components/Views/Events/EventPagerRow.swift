//
//  EventRow.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 13/10/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

var myGradient = Gradient(
    colors: [
        Color(.systemTeal),
        Color(.systemPurple),
    ]
)
struct EventPagerRow: View {
    var displayModel: EventDisplayModel
    let width: CGFloat
    var body: some View {
        EventPhotoView(photos: displayModel.photos)
            .frame(minWidth: width, minHeight: width * 0.85, maxHeight: .infinity)
            .background(Color.red)
    }
}

struct EventPhotoView: View {
    var photos: [String]

    var body: some View {
        TabView {
            ForEach(photos, id: \.self) { model in
                AsyncImage(url: URL(string: model)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)

                } placeholder: {
                    Color.blue
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))
        
    }
}

#Preview {
    EventPagerRow(displayModel: EventDisplayModel(id: 1,
                                                  title: "Dummy Event at #\(1)",
                                                  description: "This is just another dummy event, read more...",
                                                  isOwn: false,
                                                  nsfw: true,
                                                  joined: false,
                                                  coverPhoto: "https://images.pexels.com/photos/15839628/pexels-photo-15839628/free-photo-of-a-person-holding-a-coffee-cup.jpeg?auto=compress&cs=tinysrgb&w=1200&lazy=load",
                                                  photos: ["https://images.pexels.com/photos/15839628/pexels-photo-15839628/free-photo-of-a-person-holding-a-coffee-cup.jpeg?auto=compress&cs=tinysrgb&w=1200&lazy=load"],
                                                  joiners: EventJoinersDisplayModel(title: "# left", photos: []),
                                                  timeLeft: "2d left",
                                                  status: EventStatusDisplayModel(status: .live, timeLeft: "2d left")),
                  width: 300)
}
