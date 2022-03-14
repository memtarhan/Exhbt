//
//  BlockRepo.swift
//  Exhbt
//
//  Created by Shouvik Paul on 1/11/21.
//  Copyright © 2021 Exhbt LLC. All rights reserved.
//

import Foundation
import CBGPromise

class BlockRepo {
    private let collectionName = "blocked"
    
    func getBlockedUsers(for userID: String) -> Future<Result<[Block], Error>> {
        let promise = Promise<Result<[Block], Error>>()
        
        db.collection(collectionName)
            .whereField(BlockField.userID.rawValue, isEqualTo: userID)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    var returnArray: [Block] = []
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            let dict = document.data()
                            guard let block = Block(from: dict) else {
                                print("Error changing it into an object")
                                return
                            }
                            returnArray.append(block)
                        }
                    }
                    promise.resolve(.success(returnArray))
                } else {
                    print("There are no blocked users for user \(userID): \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        return promise.future
    }
    
    func getBlockedBy(for blockedID: String) -> Future<Result<[Block], Error>> {
        let promise = Promise<Result<[Block], Error>>()
        
        db.collection(collectionName)
            .whereField(BlockField.blockedID.rawValue, isEqualTo: blockedID)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    var returnArray: [Block] = []
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            let dict = document.data()
                            guard let block = Block(from: dict) else {
                                print("Error changing it into an object")
                                return
                            }
                            returnArray.append(block)
                        }
                    }
                    promise.resolve(.success(returnArray))
                } else {
                    print("There are no users blocking user \(blockedID): \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        return promise.future
    }
    
    func block(userID: String, blockedID: String) -> Future<Result<Void, Error>> {
        let promise = Promise<Result<Void, Error>>()
        
        let block = Block(userID: userID, blockedID: blockedID)
        db.collection(collectionName).addDocument(data: block.toDict()) {
            err in
            if let err = err {
                print("UserID \(userID) failed to block \(blockedID): \(err)")
                promise.resolve(.failure(GenericError.createError))
            } else {
                promise.resolve(.success(()))
            }
        }
        
        return promise.future
    }
    
    func unblock(userID: String, blockedID: String) -> Future<Result<Void, Error>> {
        let promise = Promise<Result<Void, Error>>()
        
        db.collection(collectionName)
            .whereField(BlockField.userID.rawValue, isEqualTo: userID)
            .whereField(BlockField.blockedID.rawValue, isEqualTo: blockedID)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    snapshot.documents.forEach { (document) in
                        if document.exists {
                            document.reference.delete()
                        }
                    }
                    promise.resolve(.success(()))
                } else {
                    print("UserID \(userID) failed to unblock \(blockedID): \(String(describing: error ?? nil))")
                    promise.resolve(.failure(error ?? GenericError.notFound))
                }
            })
        
        return promise.future
    }
}
