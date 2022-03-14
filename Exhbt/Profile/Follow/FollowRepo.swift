//
//  FollowRepo.swift
//  Exhbt
//
//  Created by Shouvik Paul on 9/15/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation
import CBGPromise

class FollowRepo {
    private let collectionName = "followers"
    
    func getFollowers(for userID: String) -> Future<Result<[Follow], Error>> {
        let promise = Promise<Result<[Follow], Error>>()
        
        db.collection(collectionName)
            .whereField(FollowField.followedID.rawValue, isEqualTo: userID)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    var returnArray: [Follow] = []
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            let dict = document.data()
                            guard let follow = Follow(from: dict) else {
                                print("Error changing it into an object")
                                return
                            }
                            returnArray.append(follow)
                        }
                    }
                    promise.resolve(.success(returnArray))
                } else {
                    print("There are no followers for user \(userID): \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        return promise.future
    }
    
    func getFollowing(for userID: String) -> Future<Result<[Follow], Error>> {
        let promise = Promise<Result<[Follow], Error>>()
        
        db.collection(collectionName)
            .whereField(FollowField.userID.rawValue, isEqualTo: userID)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    var returnArray: [Follow] = []
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            let dict = document.data()
                            guard let follow = Follow(from: dict) else {
                                print("Error changing it into an object")
                                return
                            }
                            returnArray.append(follow)
                        }
                    }
                    promise.resolve(.success(returnArray))
                } else {
                    print("There are no followers for user \(userID): \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        return promise.future
    }
    
    func follow(userID: String, followedID: String) -> Future<Result<Void, Error>> {
        let promise = Promise<Result<Void, Error>>()
        
        let follow = Follow(userID: userID, followedID: followedID)
        db.collection(collectionName).addDocument(data: follow.toDict()) {
            err in
            if let err = err {
                print("UserID \(userID) failed to follow \(followedID): \(err)")
                promise.resolve(.failure(GenericError.createError))
            } else {
                promise.resolve(.success(()))
            }
        }
        
        return promise.future
    }
    
    func unfollow(userID: String, followedID: String) -> Future<Result<Void, Error>> {
        let promise = Promise<Result<Void, Error>>()
        
        db.collection(collectionName)
            .whereField(FollowField.userID.rawValue, isEqualTo: userID)
            .whereField(FollowField.followedID.rawValue, isEqualTo: followedID)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            document.reference.delete()
                        }
                    }
                    promise.resolve(.success(()))
                } else {
                    print("UserID \(userID) failed to unfollow \(followedID): \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        
        return promise.future
    }
}
