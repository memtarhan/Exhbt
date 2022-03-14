//
//  NotificationRepository.swift
//  Exhbt
//
//  Created by Shouvik Paul on 6/24/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation
import CBGPromise
import Firebase

class NotificationRepository {
    private let collectionName = "notifications"
    
    func sendNotification(_ notification: Notification) -> Future<Result<Void, Error>> {
        let promise = Promise<Result<Void, Error>>()
        
        db.collection(collectionName).addDocument(data: notification.toDict()) {
            err in
            if let err = err {
                print("Failed to send notification \(notification): \(err)")
                promise.resolve(.failure(GenericError.createError))
            } else {
                promise.resolve(.success(()))
            }
        }
        
        return promise.future
    }
    
    func sendCompetitionInvites(for userIDs: [String], competition: CompetitionDataModel) -> Future<Result<Void, Error>> {
        let promise = Promise<Result<Void, Error>>()
        
        let notifications = userIDs.map {
            return Notification(
                userID: $0,
                type: .invite,
                competitionID: competition.competitionID,
                creatorID: competition.creatorID)
        }
        
        let batch = db.batch()
        
        notifications.forEach {
            let ref = db.collection(collectionName).document()
            batch.setData($0.toDict(), forDocument: ref)
        }
        
        batch.commit() { err in
            if let err = err {
                print("Error writing comp invite batch \(err)")
                promise.resolve(.failure(err))
            } else {
                print("Batch comp invite succeeded.")
                promise.resolve(.success(()))
            }
        }
        
        return promise.future
    }
    
    func getNotificationsForUser(_ userID: String) -> Future<Result<[Notification], Error>> {
        let promise = Promise<Result<[Notification], Error>>()
        
        db.collection(collectionName)
            .whereField(NotificationField.userID.rawValue, isEqualTo: userID)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    var returnArray: [Notification] = []
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            let dict = document.data()
                            guard let notif = Notification(from: dict) else {
                                print("Error chaging it into an object")
                                return
                            }
                            returnArray.append(notif)
                        }
                    }
                    promise.resolve(.success(returnArray))
                } else {
                    print("There are no notifications for user \(userID): \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        return promise.future
    }
    
    func getAllFollowRequests(_ userID: String) -> Future<Result<[Notification], Error>> {
        let promise = Promise<Result<[Notification], Error>>()
        
        db.collection(collectionName)
            .whereField(NotificationField.userID.rawValue, isEqualTo: userID)
            .whereField(NotificationField.type.rawValue, isEqualTo: NotificationType.followRequest.rawValue)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    var returnArray: [Notification] = []
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            let dict = document.data()
                            guard let notif = Notification(from: dict) else {
                                print("Error chaging it into an object")
                                return
                            }
                            returnArray.append(notif)
                        }
                    }
                    promise.resolve(.success(returnArray))
                } else {
                    print("There are no notifications for user \(userID): \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        return promise.future
    }
    
    func getCompetitionInvites(_ userID: String) -> Future<Result<[Notification], Error>> {
        let promise = Promise<Result<[Notification], Error>>()
        
        db.collection(collectionName)
            .whereField(NotificationField.userID.rawValue, isEqualTo: userID)
            .whereField(NotificationField.type.rawValue, isEqualTo: NotificationType.invite.rawValue)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    var returnArray: [Notification] = []
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            let dict = document.data()
                            guard let notif = Notification(from: dict) else {
                                print("Error chaging it into an object")
                                return
                            }
                            returnArray.append(notif)
                        }
                    }
                    promise.resolve(.success(returnArray))
                } else {
                    print("There are no notifications for user \(userID): \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        return promise.future
    }
    
    func getCompetitionResults(_ userID: String) -> Future<Result<[Notification], Error>> {
        let promise = Promise<Result<[Notification], Error>>()
        
        db.collection(collectionName)
            .whereField(NotificationField.userID.rawValue, isEqualTo: userID)
            .whereField(NotificationField.type.rawValue, isEqualTo: NotificationType.competitionExpiration.rawValue)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    var returnArray: [Notification] = []
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            let dict = document.data()
                            guard let notif = Notification(from: dict) else {
                                print("Error chaging it into an object")
                                return
                            }
                            returnArray.append(notif)
                        }
                    }
                    promise.resolve(.success(returnArray))
                } else {
                    print("There are no notifications for user \(userID): \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        return promise.future
    }
    
    func getFollowRequest(_ userID: String, followUserID: String) -> Future<Bool> {
        let promise = Promise<Bool>()
        
        db.collection(collectionName)
            .whereField(NotificationField.creatorID.rawValue, isEqualTo: userID)
            .whereField(NotificationField.userID.rawValue, isEqualTo: followUserID)
            .whereField(
                NotificationField.type.rawValue,
                isEqualTo: NotificationType.followRequest.rawValue)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    var returnBool: Bool = false
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            returnBool = true
                        }
                    }
                    promise.resolve(returnBool)
                } else {
                    print("User has not requested to follow.")
                    promise.resolve(false)
                }
            })
        return promise.future
    }
    
    func deleteFollowRequest(
        _ userID: String,
        followUserID: String) -> Future<Result<Void, Error>> {
        let promise = Promise<Result<Void, Error>>()
        
        db.collection(collectionName)
            .whereField(NotificationField.creatorID.rawValue, isEqualTo: userID)
            .whereField(NotificationField.userID.rawValue, isEqualTo: followUserID)
            .whereField(
                NotificationField.type.rawValue,
                isEqualTo: NotificationType.followRequest.rawValue)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            document.reference.delete()
                        }
                    }
                    promise.resolve(.success(()))
                } else {
                    print("Could not find follow reqeust to delete. \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        return promise.future
    }
    
    func acceptFollowRequest(
        _ userID: String,
        followUserID: String
    ) -> Future<Result<Void, Error>> {
        let promise = Promise<Result<Void, Error>>()
        
        db.collection(collectionName)
            .whereField(NotificationField.creatorID.rawValue, isEqualTo: userID)
            .whereField(NotificationField.userID.rawValue, isEqualTo: followUserID)
            .whereField(NotificationField.type.rawValue, isEqualTo: NotificationType.followRequest.rawValue)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            document.reference.updateData([
                                NotificationField.type.rawValue: NotificationType.follow.rawValue
                            ])
                        }
                    }
                    promise.resolve(.success(()))
                } else {
                    print("Could not find follow reqeust to accept. \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        return promise.future
    }
    
    func deleteCompetitionInvite(
        for notification: Notification
    ) -> Future<Result<Void, Error>> {
        guard let competitionID = notification.competitionID,
              let creatorID = notification.creatorID else {
            return PromiseHelper.futureWithValue(GenericError.notFound)
        }
        let promise = Promise<Result<Void, Error>>()
        
        db.collection(collectionName)
            .whereField(
                NotificationField.creatorID.rawValue,
                isEqualTo: creatorID)
            .whereField(
                NotificationField.userID.rawValue,
                isEqualTo: notification.userID)
            .whereField(
                NotificationField.type.rawValue,
                isEqualTo: NotificationType.invite.rawValue)
            .whereField(
                NotificationField.competitionID.rawValue,
                isEqualTo: competitionID)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            document.reference.delete()
                        }
                    }
                    promise.resolve(.success(()))
                } else {
                    print("Could not find comp invite notif to delete. \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        return promise.future
    }
    
}
