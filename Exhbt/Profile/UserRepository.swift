//
//  UserRepository.swift
//  Exhbt
//
//  Created by Shouvik Paul on 4/12/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation
import Firebase
import CBGPromise

enum GenericError: Error {
    case notFound
    case unknown
    case imageUploadError
    case createError
    case updateError
}

enum UserError: Error {
    case unknown
    case notFound
    case createError
    case galleryAddError
    case objectCastError
    case currentCompetitionAddError
}

class UserRepository {
    private let collectionName = "users"
    private let userManager = UserManager.shared
    
    func createUser(_ user: User) -> Future<Result<User, UserError>> {
        let promise = Promise<Result<User, UserError>>()
        
        db.collection(collectionName)
            .document(user.userID)
            .setData(user.toDict()) { err in
                if let err = err {
                    print("Error adding user: \(err)")
                    promise.resolve(.failure(.createError))
                } else {
                    promise.resolve(.success(user))
                }
        }
        
        return promise.future
    }
    
    func getUser(by userID: String) -> Future<Result<User, UserError>> {
        let promise = Promise<Result<User, UserError>>()
        
        db.collection(collectionName)
            .document(userID)
            .getDocument { (document, error) in
                if let document = document,
                    document.exists,
                    let userDict = document.data(),
                    let user = User(from: userDict) {
                    promise.resolve(.success(user))
                } else {
                    print("User does not exist")
                    promise.resolve(.failure(.notFound))
                }
        }
        
        return promise.future
    }
    
    func updateUser(_ user: User, coins: Int = 0) -> Future<Result<User, Error>> {
        let promise = Promise<Result<User, Error>>()
        user.coins += coins
        
        let ref = db.collection(collectionName).document(user.userID)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let doc: DocumentSnapshot
            do {
                try doc = transaction.getDocument(ref)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if let userDict = doc.data(),
                let currUser = User(from: userDict) {
                let updateduser = currUser.merge(with: user)
                transaction.setData(updateduser.toDict(), forDocument: ref)
                return updateduser
            }
            
            return nil
        }) { (object, error) in
            guard let updatedUser = object as? User else {
                let err = error ?? UserError.objectCastError
                print("User update transaction failed: \(err)")
                promise.resolve(.failure(err))
                return
            }
            print("User update transaction successfully committed: \(updatedUser)")
            promise.resolve(.success(updatedUser))
        }
        
        return promise.future
    }
    
    func addCurrentCompetition(id: String, for userID: String) -> Future<Result<Void, UserError>> {
        let promise = Promise<Result<Void, UserError>>()
        
        db.collection(collectionName)
            .document(userID)
            .updateData([
                UserField.currentCompetitionIDs.rawValue: FieldValue.arrayUnion([id])
            ]) { err in
                if let err = err {
                    print("error adding new compeition id to user's current comps: \(err)")
                    promise.resolve(.failure(.currentCompetitionAddError))
                } else {
                    print("successfully added competition to user's current comps")
                    promise.resolve(.success(()))
                }
        }
        
        return promise.future
    }
    
    func addToGallery(_ image: CompetitionImage) -> Future<Result<Void, UserError>> {
        guard !image.fromGallery else {
            return PromiseHelper.futureWithValue(())
        }
        
        let promise = Promise<Result<Void, UserError>>()
        
        db.collection(collectionName)
            .document(image.userID)
            .updateData([
                UserField.images.rawValue: FieldValue.arrayUnion([image.imageID])
            ]) { err in
                if let err = err {
                    print("error adding imageUID to user object: \(err)")
                    promise.resolve(.failure(.galleryAddError))
                } else {
                    print("successfully added image to user's gallery")
                    promise.resolve(.success(()))
                }
        }
        
        return promise.future
    }
    
    func getAllUsers(returnBlocked: Bool = false) -> Future<Result<[User], UserError>> {
        let promise = Promise<Result<[User], UserError>>()
        
        db.collection(collectionName).getDocuments(completion: { (snapshot, error) in
            if let snapshot = snapshot {
                var returnArray:[User] = []
                snapshot.documents.forEach { (document) in
                    if document.exists,
                       let user = self.createUserFromDocumentData(
                        document.data(),
                        returnBlocked: returnBlocked
                       ) {
                        returnArray.append(user)
                    }
                }
                promise.resolve(.success(returnArray))
            } else {
                print("There are no users available.")
                promise.resolve(.failure(.notFound))
            }
        })
        return promise.future
    }
    
    func getUsers(
        for category: ChallengeCategories,
        returnBlocked: Bool = false
    ) -> Future<Result<[User], UserError>> {
        let promise = Promise<Result<[User], UserError>>()
        
        db.collection(collectionName)
            .whereField(category.getCoinField().rawValue, isGreaterThan: 0)
            .order(by: category.getCoinField().rawValue, descending: true)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    var returnArray:[User] = []
                    snapshot.documents.forEach { (document) in
                        if document.exists,
                           let user = self.createUserFromDocumentData(
                            document.data(),
                            returnBlocked: returnBlocked
                           ) {
                            returnArray.append(user)
                        }
                    }
                    promise.resolve(.success(returnArray))
                } else {
                    print("There are no users available. error: \(String(describing: error))")
                    promise.resolve(.failure(.notFound))
                }
            })
        return promise.future
    }
    
    func getUsers(from userIDs: [String], returnBlocked: Bool = false) -> Future<Result<[User], UserError>> {
        let promise = Promise<Result<[User], UserError>>()
        guard userIDs.count > 0 else {
            promise.resolve(.success([]))
            return promise.future
        }
        
        db.collection(collectionName)
            .whereField(UserField.userID.rawValue, in: userIDs)
            .getDocuments(completion: {(snapshot, error) in
                if let snapshot = snapshot {
                    var returnArray:[User] = []
                    snapshot.documents.forEach { (document) in
                        if document.exists,
                           let user = self.createUserFromDocumentData(
                            document.data(),
                            returnBlocked: returnBlocked
                           ) {
                            returnArray.append(user)
                        }
                    }
                    promise.resolve(.success(returnArray))
                } else {
                    print("Could not find users from userIDs: \(userIDs)")
                    promise.resolve(.failure(.notFound))
                }
            })
        return promise.future
    }
    
    private func createUserFromDocumentData(_ data: [String: Any], returnBlocked: Bool = false) -> User? {
        guard let user = User(from: data) else { return nil }
        
        var noFlyZone = userManager.blockedByUsers
        if !returnBlocked {
            noFlyZone += userManager.blockedUsers
        }
        
        let blocked = noFlyZone.contains { $0.blockedID == user.userID  }
        guard !blocked else { return nil }
        
        return user
    }
}
