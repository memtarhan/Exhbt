//
//  LeaderboardInteractor.swift
//  Exhbt
//
//  Created by Shouvik Paul on 10/13/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation

protocol LeaderboardInteractorDelegate: AnyObject {
    func receivedLeaderboard(for category: ChallengeCategories, users: [User])
    func errorReceivingLeaderboard(_ error: Error)
}

class LeaderboardInteractor {
    weak var delegate: LeaderboardInteractorDelegate?
    
    let userRepo = UserRepository()
    let userManager = UserManager.shared
    
    func getLeaderboard(for category: ChallengeCategories) {
        userRepo.getUsers(for: category).then {
            [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let users):
                self.delegate?.receivedLeaderboard(for: category, users: users)
            case .failure(let error):
                self.delegate?.errorReceivingLeaderboard(error)
            }
        }
    }
}
