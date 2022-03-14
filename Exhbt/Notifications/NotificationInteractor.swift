//
//  NotificationInteractor.swift
//  Exhbt
//
//  Created by Steven Worrall on 6/26/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation
import CBGPromise

protocol NotificationInteractorDelegate: AnyObject {
    func didReceiveNotifications(
        _ notifications: [Any],
        index: NotificationArrayIndex)
    func errorReceivingNotifications(_ error: Error, index: NotificationArrayIndex)
}

struct CompetitionResultNotification {
    let notification: Notification
    let competition: CompetitionDataModel
}

class NotificationInteractor {
    weak var delegate: NotificationInteractorDelegate?
    
    var notificationRepo = NotificationRepository()
    var competitionRepo = CompetitionRepo()
    var userRepo = UserRepository()
    private let userManager = UserManager.shared
    
    let fakeNotifs = [
        Notification(
            userID: "",
            type: .competitionExpiration,
            competitionID: "7A574D24-F7D9-444F-8BD4-F538F2460D5E",
            coins: 0),
        Notification(
            userID: "",
            type: .competitionExpiration,
            competitionID: "7A574D24-F7D9-444F-8BD4-F538F2460D5E",
            coins: 20),
        Notification(
            userID: "",
            type: .competitionExpiration,
            competitionID: "7A574D24-F7D9-444F-8BD4-F538F2460D5E",
            coins: -10),
        Notification(
            userID: "",
            type: .invite,
            competitionID: "7A574D24-F7D9-444F-8BD4-F538F2460D5E")
    ]
    
    func getNotifications(for userID: String) {
        self.notificationRepo.getAllFollowRequests(userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let notes):
                let notifications = notes.sorted(by: {
                    $0.createdDate.compare($1.createdDate) == .orderedDescending
                })
                self.processNotifications(
                    notifications,
                    index: NotificationArrayIndex.requests)
            case .failure(let error):
                self.delegate?.errorReceivingNotifications(error, index: .requests)
            }
        }
        
        self.notificationRepo.getCompetitionInvites(userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let notes):
                let notifications = notes.sorted(by: {
                    $0.createdDate.compare($1.createdDate) == .orderedDescending
                })
                self.processNotifications(
                    notifications,
                    index: NotificationArrayIndex.invites)
            case .failure(let error):
                self.delegate?.errorReceivingNotifications(error, index: .invites)
            }
        }
        
        self.notificationRepo.getCompetitionResults(userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let notes):
                let notifications = notes.sorted(by: {
                    $0.createdDate.compare($1.createdDate) == .orderedDescending
                })
                self.getCompetitionsForResults(notes: notifications)
            case .failure(let error):
                self.delegate?.errorReceivingNotifications(error, index: .invites)
            }
        }
    }
    
    private func getCompetitionsForResults(notes: [Notification]) {
        var futures: [Future<CompetitionResultNotification?>] = []
        
        notes.forEach { (note) in
            let promise = Promise<CompetitionResultNotification?>()
            futures.append(promise.future)
            
            guard let competitionID = note.competitionID else {
                promise.resolve(nil)
                return
            }
            
            self.getCompetition(competitionID).then {
                [weak self] comp in
                guard let _ = self else { return }

                if let comp = comp {
                    let result = CompetitionResultNotification(
                        notification: note,
                        competition: comp)
                    promise.resolve(result)
                } else {
                    promise.resolve(nil)
                }
            }
        }
        
        if futures.count == 0 {
            delegate?.didReceiveNotifications([], index: .results)
            return
        }
        
        Promise<CompetitionResultNotification>.when(futures).then {
            [weak self] results in
            guard let self = self else { return }

            var resultNotifs = [CompetitionResultNotification]()
            results.forEach {
                if let result = $0 { resultNotifs.append(result) }
            }
            self.delegate?.didReceiveNotifications(resultNotifs, index: .results)
        }
    }
    
    private func processNotifications(
        _ notes: [Notification],
        index: NotificationArrayIndex
    ) {
        var notificationFutures: [Future<Notification?>] = []
        
        notes.forEach { (note) in
            let promise = Promise<Notification?>()
            notificationFutures.append(promise.future)
            
            guard let creatorID = note.creatorID else {
                promise.resolve(note)
                return
            }
            
            self.getUser(userID: creatorID).then {
                [weak self] result in
                guard let _ = self else { return }

                switch result {
                case .success(let user):
                    var notification = note
                    notification.creator = user
                    promise.resolve(notification)
                case .failure(let error):
                    print("error getting user \(String(describing: note.creatorID)). error: \(error)")
                    promise.resolve(nil)
                }
            }
        }
        
        if notificationFutures.count == 0 {
            delegate?.didReceiveNotifications([], index: index)
            return
        }
        
        Promise<Notification>.when(notificationFutures).then {
            [weak self] notifications in
            guard let self = self else { return }

            var notifs = [Notification]()
            notifications.forEach {
                if let note = $0 { notifs.append(note) }
            }
            self.delegate?.didReceiveNotifications(notifs, index: index)
        }
    }
    
    func getCurrentCompetitions(competitionIDs: [String]) {
        let competitionFutures = competitionIDs.map { return getCompetition($0) }
        
        if competitionFutures.count == 0 {
            delegate?.didReceiveNotifications([], index: .current)
            return
        }
        
        Promise<CompetitionDataModel>.when(competitionFutures).then {
            [weak self] competitions in
            guard let self = self else { return }
            
            var currentCompetitions: [CompetitionDataModel] = []
            competitions.forEach {
                if let comp = $0 {
                    currentCompetitions.append(comp)
                }
            }
            
            self.delegate?.didReceiveNotifications(
                currentCompetitions,
                index: .current)
        }
    }
    
    private func getCompetition(_ competitionID: String) -> Future<CompetitionDataModel?> {
        let promise = Promise<CompetitionDataModel?>()
        
        competitionRepo.getCompetition(by: competitionID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let comp):
                self.getUser(userID: comp.creatorID).then {
                    [weak self] result in
                    guard let _ = self else { return }
                    switch result {
                    case .success(let user):
                        var competition = comp
                        competition.creator = user
                        promise.resolve(competition)
                    case .failure(let error):
                        print("error getting competition \(competitionID). error: \(error)")
                        promise.resolve(nil)
                    }
                }
            case .failure(let error):
                print("error getting competition \(competitionID). error: \(error)")
                promise.resolve(nil)
            }
        }
        
        return promise.future
    }
    
    private func getUser(userID: String) -> Future<Result<User, UserError>> {
        let promise = Promise<Result<User, UserError>>()
        
        userRepo.getUser(by: userID).then {
            [weak self] result in
            guard let _ = self else { return }

            switch result {
            case .success(let user):
                promise.resolve(.success(user))
            case .failure(let error):
                print("error getting competition creator: \(error)")
                promise.resolve(.failure(error))
            }
        }
        return promise.future
    }
    
    func deleteFollowRequest(from userID: String, followUserID: String) {
        _ = notificationRepo.deleteFollowRequest(userID, followUserID: followUserID)
    }
    
    func acceptFollowRequest(from userID: String, followUserID: String) {
        notificationRepo.acceptFollowRequest(userID, followUserID: followUserID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.userManager.followers.append(Follow(userID: userID, followedID: followUserID))
            case .failure(let error):
                print("There as an error accepting the follow request: \(error)")
            }
        }
    }
    
    func deleteCompetitionInvite(for notification: Notification) {
        _ = notificationRepo.deleteCompetitionInvite(for: notification)
    }
}
