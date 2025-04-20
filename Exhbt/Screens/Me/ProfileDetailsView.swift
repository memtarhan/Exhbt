//
//  ProfileDetailsView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 12/08/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct ProfileDetailsView: View {
    var details: MeDetailsDisplayModel

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            ProfileDetailsTopView(details: details)

            ProfileDetailsMiddleView(details: details)

            ProfileDetailsBottomView(details: details)

            Spacer()
        }
    }
}

struct ProfileDetailsTopView: View {
    var details: MeDetailsDisplayModel

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 24) {
                Spacer()
                VStack(alignment: .center, spacing: 4) {
                    HStack(spacing: 2) {
                        Image("CoinIcon")
                        Text(details.coinsCount)
                            .font(.system(size: 20, weight: .bold))
                    }
                    Text("Coins total")
                        .font(.system(size: 12))
                }

                AsyncImage(url: details.profilePhotoURL) { image in
                    image.resizable()
                } placeholder: {
                    Color.blue
                }

                .frame(width: geometry.size.width / 3, height: geometry.size.width / 3)
                .clipShape(Circle())

                VStack(alignment: .center, spacing: 4) {
                    HStack(spacing: 2) {
                        Image("PrizeIcon")
                        Text(details.prizesCount)
                            .font(.system(size: 20, weight: .bold))
                    }
                    Text("Prizes won")
                        .font(.system(size: 12))
                }

                Spacer()
            }
        }
    }
}

struct ProfileDetailsMiddleView: View {
    var details: MeDetailsDisplayModel

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            VStack {
                if let fullName = details.fullName {
                    Text(fullName)
                        .font(.system(size: 24, weight: .bold))
                }

                if let username = details.username {
                    Text(username)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            Button {
            } label: {
                Text("Edit")
                    .padding(.horizontal, 32)
            }
            .buttonStyle(.bordered)
            .foregroundColor(.black)
            .clipShape(Capsule())

            if let bio = details.bio {
                ExpandableText(bio, lineLimit: 3)
                    .padding(.horizontal, 16)
            }
        }
    }
}

struct ProfileDetailsBottomView: View {
    var details: MeDetailsDisplayModel

    var body: some View {
        HStack(alignment: .center, spacing: 24) {
            VStack {
                Text(details.votesCount)
                    .font(.system(size: 20, weight: .bold))
                Text("Votes")
            }

            Divider()

            VStack {
                Text(details.followersCount)
                    .font(.system(size: 20, weight: .bold))
                Text("Followers")
            }

            Divider()

            VStack {
                Text(details.followingsCount)
                    .font(.system(size: 20, weight: .bold))
                Text("Followings")
            }
        }
    }
}

struct ExpandableText: View {
    @State private var expanded: Bool = false
    @State private var truncated: Bool = false
    @State private var shrinkText: String

    private var text: String
    let font: UIFont
    let lineLimit: Int

    init(_ text: String, lineLimit: Int, font: UIFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)) {
        self.text = text
        _shrinkText = State(wrappedValue: text)
        self.lineLimit = lineLimit
        self.font = font
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                Text(self.expanded ? text : shrinkText) + Text(moreLessText)
                    .bold()
                    .foregroundColor(.black)
            }
            .animation(.easeInOut(duration: 1.0), value: false)
            .lineLimit(expanded ? nil : lineLimit)
            .background(
                // Render the limited text and measure its size
                Text(text)
                    .lineLimit(lineLimit)
                    .background(GeometryReader { visibleTextGeometry in
                        Color.clear.onAppear {
                            let size = CGSize(width: visibleTextGeometry.size.width, height: .greatestFiniteMagnitude)
                            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]

                            /// Binary search until mid == low && mid == high
                            var low = 0
                            var heigh = shrinkText.count
                            var mid = heigh /// start from top so that if text contain we does not need to loop
                            ///
                            while (heigh - low) > 1 {
                                let attributedText = NSAttributedString(string: shrinkText + moreLessText, attributes: attributes)
                                let boundingRect = attributedText.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                                if boundingRect.size.height > visibleTextGeometry.size.height {
                                    truncated = true
                                    heigh = mid
                                    mid = (heigh + low) / 2

                                } else {
                                    if mid == text.count {
                                        break
                                    } else {
                                        low = mid
                                        mid = (low + heigh) / 2
                                    }
                                }
                                shrinkText = String(text.prefix(mid))
                            }
                            
                            // TODO: Fix this crash

//                            if truncated {
//                                shrinkText = String(shrinkText.prefix(shrinkText.count - 2)) // -2 extra as highlighted text is bold
//                            }
                        }
                    })
                    .hidden() // Hide the background
            )
            .font(Font(font)) /// set default font
            ///
            if truncated {
                Button(action: {
                    expanded.toggle()
                }, label: {
                    HStack { // taking tap on only last line, As it is not possible to get 'see more' location
                        Spacer()
                        Text("")
                    }.opacity(0)
                })
                .foregroundColor(.blue)
            }
        }
    }

    private var moreLessText: String {
        if !truncated {
            return ""
        } else {
            return expanded ? " Read less" : " ... Read more"
        }
    }
}

struct ProfileDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileDetailsView(details: MeDetailsDisplayModel.sample)
    }
}
