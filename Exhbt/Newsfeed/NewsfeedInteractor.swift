//
//  NewsfeedInteractor.swift
//  Exhbt
//
//  Created by Steven Worrall on 6/5/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation
import CBGPromise

protocol NewsfeedInteractorDelegate: AnyObject {
    func didReceiveCompetitions(competitions: [CompetitionDataModel])
    func errorReceivingCompetitions(error: CompetitionError)
    func didReceiveCompetition(_ competition: CompetitionDataModel)
    func errorReceivingCompetition(_ error: CompetitionError)
}

extension NewsfeedInteractorDelegate {
    func didReceiveCompetitions(competitions: [CompetitionDataModel]) {}
    func errorReceivingCompetitions(error: CompetitionError) {}
    func didReceiveCompetition(_ competition: CompetitionDataModel) {}
    func errorReceivingCompetition(_ error: CompetitionError) {}
}

class NewsfeedInteractor {
    weak var delegate: NewsfeedInteractorDelegate?
    
    let competitionRepo = CompetitionRepo()
    let userRepo = UserRepository()
    let userManager = UserManager.shared
    
    private var fetchingCompetitions = false
    
    func getCompetitions(refresh: Bool = false) {
        guard !fetchingCompetitions else {
            return
        }
        fetchingCompetitions = true
        
        competitionRepo.getCompetitions(fresh: refresh).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let comps):
                self.delegate?.didReceiveCompetitions(competitions: comps)
            case .failure(let error):
                self.delegate?.errorReceivingCompetitions(error: error)
            }
            self.fetchingCompetitions = false
        }
    }
    
    func getCompetition(by competitionID: String) {
        competitionRepo.getCompetition(by: competitionID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let comp):
                self.delegate?.didReceiveCompetition(comp)
            case .failure(let error):
                self.delegate?.errorReceivingCompetition(error)
            }
        }
    }
    
    public func updateCompetitionWithVotes(
        comp: CompetitionDataModel,
        votedImages: Set<String>
    ) {
        guard let user = UserManager.shared.user else { return }
        var indexes = [Int]()
        for (idx, image) in comp.challengeImages.enumerated() {
            if votedImages.contains(image.imageID) {
                indexes.append(idx)
            }
        }
        competitionRepo.updateCompetitionVotes(
            competition: comp,
            photoIndexes: indexes,
            voter: user.userID
        )
        userRepo.updateUser(user, coins: AppConstants.CoinsForVoting).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.userManager.setUser(user)
            case .failure(let error):
                print("Error adding coins to user on vote: \(error)")
            }
        }
    }
}
