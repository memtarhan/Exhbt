//
//  CompetitionInteractor.swift
//  Exhbt
//
//  Created by Shouvik Paul on 6/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation
import CBGPromise

protocol CompetitionInteractorDelegate: AnyObject {
    func createdCompetition(_ competition: CompetitionDataModel)
    func errorCreatingCompetition(for competitionID: String, _ error: Error)
    func receivedCompetition(_ competition: CompetitionDataModel)
    func errorReceivingCompetition(_ error: Error)
    func joinedCompetition(_ competition: CompetitionDataModel)
    func errorJoiningCompeition(_ error: Error)
}

extension CompetitionInteractorDelegate {
    func createdCompetition(_ competition: CompetitionDataModel) {}
    func errorCreatingCompetition(for competitionID: String, _ error: Error) {}
    func receivedCompetition(_ competition: CompetitionDataModel) {}
    func errorReceivingCompetition(_ error: Error) {}
    func joinedCompetition(_ competition: CompetitionDataModel) {}
    func errorJoiningCompeition(_ error: Error) {}
}

class CompetitionInteractor {
    weak var delegate: CompetitionInteractorDelegate?
    let competitionRepo = CompetitionRepo()
    let userRepo = UserRepository()
    let imageRepo = ImageRepository()
    let notifRepo = NotificationRepository()
    let userManager = UserManager.shared
    
    func getCompetitionForInvite(by id: String) {
        competitionRepo.getCompetition(by: id).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let comp):
                self.getCreatorInfo(for: comp)
            case .failure(let error):
                self.delegate?.errorReceivingCompetition(error)
            }
        }
    }
    
    func createCompetition(_ competition: CompetitionDataModel) {
        competitionRepo.createCompetition(competition: competition).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let competition):
                print("success uploading competition: \(competition)")
                if let image = competition.challengeImages.first {
                    self.updateUserWithCompetitionData(
                        competitionID: competition.competitionID,
                        with: image)
                }
                self.removeCoinsForCreatingCompetition(creatorID: competition.creatorID)
                self.delegate?.createdCompetition(competition)
            case .failure(let error):
                print("error uploading competition: \(error)")
                self.delegate?.errorCreatingCompetition(for: competition.competitionID, error)
            }
        }
    }
    
    func joinCompetition(
        _ competition: CompetitionDataModel,
        with newImage: CompetitionImage
    ) {
        guard let image = newImage.image else {
            return
        }
        imageRepo.uploadImage(image, with: newImage.imageID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.addImageToCompetition(competition, image: newImage)
                let notif = Notification(userID: newImage.userID, type: .invite, competitionID: competition.competitionID, creatorID: competition.creatorID)
                _ = self.notifRepo.deleteCompetitionInvite(for: notif)
                self.imageRepo.uploadImageForRestOfSizes(
                    image: image,
                    ID: newImage.imageID,
                    sizes: [.tiny, .small]
                )
            case .failure(let error):
                self.delegate?.errorJoiningCompeition(error)
            }
        }
    }
    
    private func addImageToCompetition(
        _ competition: CompetitionDataModel,
        image: CompetitionImage
    ) {
        competitionRepo.addCompetitionImageAndSetLiveIfNecessary(
            id: competition.competitionID,
            image: image,
            setLive: competition.challengeImages.count + 1 >= 4
        ).then { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.updateUserWithCompetitionData(
                    competitionID: competition.competitionID,
                    with: image)
                self.delegate?.joinedCompetition(competition)
            case .failure(let error):
                self.delegate?.errorJoiningCompeition(error)
            }
        }
    }
    
    private func updateUserWithCompetitionData(competitionID: String, with image: CompetitionImage) {
        let currentCompFuture = userRepo.addCurrentCompetition(id: competitionID, for: image.userID)
        let addToGalleryFuture = userRepo.addToGallery(image)
        
        Promise<Void>.when([currentCompFuture, addToGalleryFuture]).then { [weak self] _ in
            self?.userRepo.getUser(by: image.userID).then {
                [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let user):
                    self.userManager.setUser(user)
                    print("updated local version of user with backend")
                case .failure(let error):
                    print("error getting latest version of current user: \(error)")
                }
            }
        }
    }

    private func getCreatorInfo(for comp: CompetitionDataModel) {
        var competition = comp
        userRepo.getUser(by: comp.creatorID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                competition.creator = user
                self.delegate?.receivedCompetition(competition)
            case .failure(let error):
                self.delegate?.errorReceivingCompetition(error)
            }
        }
    }
    
    private func removeCoinsForCreatingCompetition(creatorID: String) {
        guard let user = userManager.user, user.userID == creatorID else { return }
        userRepo.updateUser(user, coins: AppConstants.CoinsForCreatingCompetition).then {
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
