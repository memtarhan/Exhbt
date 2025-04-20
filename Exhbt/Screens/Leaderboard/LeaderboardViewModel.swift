//
//  LeaderboardViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

final class LeaderboardViewModel: ObservableObject {
    var model: LeaderboardModel!

    var navigationAction: IntHandler?

    @Published var tags: [TagDisplayModel] = []
    @Published var leaderboardUsers: [LeaderboardUserDisplayModel] = []
    @Published var searchText: String = ""
    private var page = 0

    var selectedTag: TagDisplayModel?
    private lazy var defaultCategories = Category.displayableList

    func loadTags() {
        tags.removeAll()
        Task {
            do {
                let model = try await model.getPopularTags()
                // TODO: Remove this, make this class @MainActor
                DispatchQueue.main.async {
                    let tags = model.map { TagDisplayModel(id: $0.id, title: $0.label) }
                    self.tags = tags
                }
            } catch {
                debugLog(self, error)
            }
        }
    }

    func load() {
        page += 1
        
        Task {
            do {
                var keyword: String?
                if !searchText.isEmpty { keyword = searchText }
                
                let users = try await self.model.get(forTag: selectedTag?.title, keyword: keyword, page: page, limit: 20)
                let models = users.map { LeaderboardUserDisplayModel(
                    id: $0.id,
                    rankNumber: "\($0.rank.number)",
                    rankType: $0.rank.type,
                    photoURL: $0.profilePhoto,
                    username: $0.username,
                    score: "\($0.score)")
                }
                if !models.isEmpty {
                    DispatchQueue.main.async {
                        self.leaderboardUsers += models
                    }
                }

            } catch {
                debugLog(self, error)
            }
        }
    }

    func resetUsers() {
        page = 0
        leaderboardUsers.removeAll()
    }


    func showUserDetail(userId: Int) {
        navigationAction?(userId)
    }
}
