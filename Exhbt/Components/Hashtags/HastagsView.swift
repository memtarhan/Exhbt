//
//  LeaderboardHastagView.swift
//  Exhbt
//
//  Created by Kemal Ekren on 4.08.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

fileprivate let colors = [
    Color("LeaderboardHastagGradient1"),
    Color("LeaderboardHastagGradient2"),
    Color("LeaderboardHastagGradient3"),
    Color("LeaderboardHastagGradient4"),
    Color("LeaderboardHastagGradient5"),
    Color("LeaderboardHastagGradient6"),
]

enum LeaderboardHastagConstant {
    static let headerText: String = "Most Popular"
    static let trendingIcon: Image = Image("LeaderboardTrendingIcon")
    static let gradientColor1: Color = Color("LeaderboardHastagGradient1")
    static let gradientColor2: Color = Color("LeaderboardHastagGradient2")
    static let gradientColor3: Color = Color("LeaderboardHastagGradient3")
    static let gradientColor4: Color = Color("LeaderboardHastagGradient4")
    static let gradientColor5: Color = Color("LeaderboardHastagGradient5")
    static let gradientColor6: Color = Color("LeaderboardHastagGradient6")
    static let hastagGradientColor: LinearGradient = LinearGradient(colors: [gradientColor1, gradientColor2], startPoint: .leading, endPoint: .trailing)
    static let hastagGradientColor2: LinearGradient = LinearGradient(colors: [gradientColor3, gradientColor4], startPoint: .leading, endPoint: .trailing)
    static let hastagGradientColor3: LinearGradient = LinearGradient(colors: [gradientColor5, gradientColor6], startPoint: .leading, endPoint: .trailing)
}

struct HastagsView: View {
    var tags: [TagDisplayModel]
    var selectedTag: CustomHandler<TagDisplayModel?>?
    @State private var tag: TagDisplayModel? = nil

    private var displayTags: [[TagDisplayModel]] {
        tags.chunked(into: 8)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(alignment: .center, spacing: 0) {
                    Text(LeaderboardHastagConstant.headerText)
                        .font(.system(size: 14, weight: .bold))
                    LeaderboardHastagConstant.trendingIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.leading, 5)
                }
                .padding(.bottom, 8)

                Spacer()

                if let tag {
                    HStack {
                        Text("\(tag.title)")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background((colors.randomElement() ?? colors[0]).opacity(0.2))
                            .foregroundColor(.black.opacity(0.7))
                            .clipShape(Capsule())

                        Button {
                            self.tag = nil
                            selectedTag?(nil)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .padding(.vertical, 4)
                        .tint(Color.blue)
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(displayTags, id: \.self) { innerTags in
                        LazyHStack(alignment: .center, spacing: 8) {
                            ForEach(innerTags) { tag in
                                HastagView(tag: tag.title)
                                    .onTapGesture {
                                        selectedTag?(tag)
                                        self.tag = tag
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct UserTagsView: View {
    var tags: [TagDisplayModel]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 8) {
                ForEach(tags) { tag in
                    UserHastagView(tag: tag.title)
                }
            }
        }
    }
}

struct UserHastagView: View {
    var tag: String

    var body: some View {
        Text("\(tag)")
            .foregroundColor(LeaderboardSearchConstant.searchBarPlaceholderColor)
            .padding(6)
            .overlay {
                Capsule()
                    .stroke(colors.randomElement() ?? colors[0], lineWidth: 1)
            }
    }
}

struct HastagView: View {
    var tag: String

    var body: some View {
        Text("\(tag)")
            .foregroundColor(LeaderboardSearchConstant.searchBarPlaceholderColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .overlay {
                Capsule()
                    .stroke(colors.randomElement() ?? colors[0], lineWidth: 1)
            }
    }
}

struct LeaderboardHastagView_Previews: PreviewProvider {
    static var previews: some View {
        HastagsView(tags: sampleHashtags)
    }
}

fileprivate let sampleHashtags = (0 ..< 24).map { TagDisplayModel(id: $0, title: "Tag #\($0)") }
