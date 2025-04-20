//
//  LeaderboardScene.swift
//  Exhbt
//
//  Created by Kemal Ekren on 3.08.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct LeaderboardScene: View {
    @StateObject var viewModel: LeaderboardViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                HastagsView(tags: viewModel.tags, selectedTag: { tag in
                    self.viewModel.selectedTag = tag
                    self.viewModel.resetUsers()
                    self.viewModel.load()
                })
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.leaderboardUsers) { user in
                            LeaderboardUserRow(userModel: user)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                                .onTapGesture {
                                    viewModel.showUserDetail(userId: user.id)
                                }
                        }
                    }
                }
                .refreshable {
                    viewModel.load()
                }

                Spacer()
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $viewModel.searchText)
        .tint(.blue)

        .onChange(of: viewModel.searchText) { _ in
            viewModel.resetUsers()
            viewModel.load()
        }

        .onAppear {
            viewModel.load()
        }
    }
}

struct LeaderboardScene_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardScene(viewModel: LeaderboardViewModel())
    }
}
