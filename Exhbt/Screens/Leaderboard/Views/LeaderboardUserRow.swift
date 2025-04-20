//
//  LeaderboardUserRow.swift
//  Exhbt
//
//  Created by Kemal Ekren on 3.08.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Kingfisher
import SwiftUI

enum LeaderboardUserRowConstant {
    static let profileImageOverlay: String = "LeaderboardProfileIconOverlay"
    static let mockProfileImage: String = "LeaderboardMockProfileImage"
    static let firstRankIcon: Image = Image("LeaderboardFirstRankIcon")
    static let secondRankIcon: Image = Image("LeaderboardSecondRankIcon")
    static let thirdRankIcon: Image = Image("LeaderboardThirdRankIcon")
}

struct LeaderboardUserRow: View {
    var userModel: LeaderboardUserDisplayModel

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            createRankView()

            Image(LeaderboardUserRowConstant.profileImageOverlay)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
                .overlay {
                    KFImage(profilePhotoURL)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                }

            VStack(alignment: .leading, spacing: 0) {
                Text(userModel.username ?? "")
                    .font(.system(size: 14, weight: .bold))
                Text("Score: \(userModel.score)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(LeaderboardSearchConstant.searchBarPlaceholderColor)
            }
            .padding(.leading, 8)

            Spacer()
        }
        .padding(10)

        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 0.3)
        )
        .background(Color(uiColor: .systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 7)
    }
}

private extension LeaderboardUserRow {
    @ViewBuilder
    func createRankView() -> some View {
        switch userModel.rankType {
        case .gold:
            LeaderboardUserRowConstant.firstRankIcon
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(.trailing, 16)
        case .bronze:
            LeaderboardUserRowConstant.thirdRankIcon
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(.trailing, 16)
        case .silver:
            LeaderboardUserRowConstant.secondRankIcon
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(.trailing, 16)
        default:
            Text("\(userModel.rankNumber)")
                .font(.system(size: 14, weight: .regular))
                .frame(width: 24, height: 24)
                .padding(.trailing, 16)
        }
    }

    var profilePhotoURL: URL? {
        if let url = userModel.photoURL {
            return URL(string: url)
        }
        return nil
    }
}

struct LeaderboardUserRow_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardUserRow(
            userModel: LeaderboardUserDisplayModel(
                id: 0,
                rankNumber: "12",
                rankType: .regular,
                photoURL: "",
                username: "sampleUser",
                score: "30"
            )
        )
    }
}
