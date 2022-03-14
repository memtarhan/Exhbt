//
//  CompetitionRepo.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/11/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation
import Firebase
import CBGPromise

let storage = Storage.storage()
let db = Firestore.firestore()

enum CompetitionError: Error {
    case unknown
    case notFound
    case createError
    case updateError
    case parseImageError
    case currentCompetitionAddError
}

class CompetitionRepo {
    private let collectionName = "competitions"

    func createCompetition(competition: CompetitionDataModel) -> Future<Result<CompetitionDataModel, CompetitionError>> {
        let promise = Promise<Result<CompetitionDataModel, CompetitionError>>()
        
        db.collection(collectionName).document(competition.competitionID).setData(competition.toDict()) { err in
            if let err = err {
                print("Error adding competition: \(err)")
                promise.resolve(.failure(.createError))
            } else {
                promise.resolve(.success(competition))
            }
        }
        return promise.future
    }
    
    func getCompetition(by id: String) -> Future<Result<CompetitionDataModel, CompetitionError>> {
        let promise = Promise<Result<CompetitionDataModel, CompetitionError>>()
        
        db.collection(collectionName)
            .document(id)
            .getDocument { (document, error) in
            if let document = document,
                document.exists,
                let dict = document.data(),
                let user = CompetitionDataModel(from: dict) {
                promise.resolve(.success(user))
            } else {
                print("Competition does not exist")
                promise.resolve(.failure(.notFound))
            }
        }
        
        return promise.future
    }
    
    private var lastComp: CompetitionDataModel? = nil

    func getCompetitions(fresh: Bool = false) -> Future<Result<[CompetitionDataModel], CompetitionError>> {
        if fresh {
            lastComp = nil
        }
        let promise = Promise<Result<[CompetitionDataModel], CompetitionError>>()

        var ref = db.collection(collectionName)
            .whereField(
                CompetitionFields.state.rawValue,
                in: [CompetitionState.live.rawValue, CompetitionState.expired.rawValue]
            ).order(by: CompetitionFields.createdAt.rawValue, descending: true)

        if let lastComp = lastComp {
            ref = ref.start(after: [lastComp.createdAt])
        }

        ref.limit(to: 20).getDocuments(completion: { (snapshot, error) in
            if let snapshot = snapshot {
                var returnArray:[CompetitionDataModel] = []
                snapshot.documents.forEach { (document) in
                    if document.exists {
                        let dict = document.data()
                        guard let comp = CompetitionDataModel(from: dict) else { return }
                        returnArray.append(comp)
                    }
                    if !returnArray.isEmpty {
                        self.lastComp = returnArray[returnArray.count - 1]
                    }
                }
                promise.resolve(.success(returnArray))
            } else {
                print("There are no competitions available.")
                promise.resolve(.failure(.notFound))
            }
        })
        return promise.future
    }

    func addCompetitionImageAndSetLiveIfNecessary(
        id: String,
        image: CompetitionImage,
        setLive: Bool
    ) -> Future<Result<Void, CompetitionError>> {
        let promise = Promise<Result<Void, CompetitionError>>()
        
        var addedData: [String: Any] = [
            CompetitionFields.images.rawValue: FieldValue.arrayUnion([image.toDict()])
        ]
        if setLive {
            addedData[CompetitionFields.liveAt.rawValue] = Utilities.getCurrentDateString()
            addedData[CompetitionFields.state.rawValue] = CompetitionState.live.rawValue
        }

        db.collection(collectionName)
            .document(id)
            .updateData(addedData) { err in
                if let err = err {
                    print("error adding new compeition id to user's current comps: \(err)")
                    promise.resolve(.failure(.currentCompetitionAddError))
                } else {
                    promise.resolve(.success(()))
                }
        }
        
        return promise.future
    }
    
    func updateCompetitionVotes(
        competition: CompetitionDataModel,
        photoIndexes: [Int],
        voter: String
    ) {
        guard !photoIndexes.isEmpty else { return }
        let ref = db.collection(collectionName).document(competition.competitionID)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let doc: DocumentSnapshot
            do {
                try doc = transaction.getDocument(ref)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var imageArray = doc.data()?[CompetitionFields.images.rawValue] as? [Any]
            else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve image array from snapshot \(doc)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
            }
            
            for index in photoIndexes {
                guard index < imageArray.count,
                      index >= 0 else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Image index \(index) does not exist in images array. image count: \(imageArray.count) \(doc)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                if var imageObj = imageArray[index] as? [String: Any],
                   let oldVote = imageObj[CompetitionImageFields.votes.rawValue] as? Int {
                    imageObj[CompetitionImageFields.votes.rawValue] = oldVote + 1
                    var voters = imageObj[CompetitionImageFields.voters.rawValue] as? [String] ?? []
                    voters.append(voter)
                    imageObj[CompetitionImageFields.voters.rawValue] = voters
                    imageArray[index] = imageObj
                } else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve image object from snapshot \(doc)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
            }

            transaction.updateData([
                CompetitionFields.images.rawValue: imageArray
            ],
            forDocument: ref)
            return nil
            
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
}


