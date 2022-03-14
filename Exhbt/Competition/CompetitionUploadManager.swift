//
//  File.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/4/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation
import UIKit
import Firebase

protocol CompetitionUploadManagerDelegate: AnyObject {
    func createUploadBar(competition: CompetitionDataModel)
    func updateBarWithPercent(competition: CompetitionDataModel, percent: CGFloat)
}

class CompetitionUploadManager {
    static let shared = CompetitionUploadManager()
    
    weak var delegate: CompetitionUploadManagerDelegate?
    
    lazy var competitionInteractor: CompetitionInteractor = {
        let interactor = CompetitionInteractor()
        interactor.delegate = self
        return interactor
    }()
    let imageRepo = ImageRepository()
    
    init() {
    }
    
    private let competitionCollectionName = "competitions"
    private let imageUUIDCollectionName = "imageUUID"
    private let userCollectionName = "users"
    
    public func createCompetition(competition: CompetitionDataModel) {
        self.uploadCompetitionImage(competition: competition)
    }
    
    private func uploadCompetitionImage(competition: CompetitionDataModel) {
        self.createUploadBar(competition: competition)
        
        guard let image = competition.challengeImages.first?.image,
            let localFile = Utilities.getTempImageURL(image: image),
            let imageID = competition.challengeImages.first?.imageID else { return }

        let storageRef = storage.reference(withPath: Utilities.createStoredImageLink(with: imageID))
        let uploadTask = storageRef.putFile(from: localFile)

        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("update with percent \(percentComplete)")
            self.updateUploadBar(competition: competition, percent: CGFloat(percentComplete))
        }

        uploadTask.observe(.success) { snapshot in
            print("uploaded imageID \(imageID)")
            self.updateUploadBar(competition: competition, percent: 100)
            self.finishCreatingCompetition(competition)
            self.imageRepo.uploadImageForRestOfSizes(
                image: image,
                ID: imageID,
                sizes: [.tiny, .small]
            )
        }

        uploadTask.observe(.failure) { snapshot in
            print("Error uploading imageID \(imageID): \(snapshot.error as NSError?)")
            self.presentError(for: competition.competitionID)
        }
    }
    
    private func finishCreatingCompetition(_ competition: CompetitionDataModel) {
        competitionInteractor.createCompetition(competition)
    }
    
    private func createUploadBar(competition: CompetitionDataModel) {
        DispatchQueue.main.async {
            self.delegate?.createUploadBar(competition: competition)
        }
    }
    
    private func updateUploadBar(competition: CompetitionDataModel, percent: CGFloat) {
        DispatchQueue.main.async {
            self.delegate?.updateBarWithPercent(competition: competition, percent: percent)
        }
    }
    
    public func testUploadBar(competition: CompetitionDataModel) {
        self.createUploadBar(competition: competition)
        // if we don't give it a second it hides bc the bar bounds aren't set
        usleep(200000)
        self.updateFakeUploadBar(competition: competition)
    }
    
    private func updateFakeUploadBar(competition: CompetitionDataModel) {
        for _ in 0...100 {
            DispatchQueue.main.async {
                self.delegate?.updateBarWithPercent(competition: competition, percent: 1)
            }
            usleep(2000)
        }
    }
    
    private func presentError(for competitionID: String) {
        /// TODO: alert user that competition failed to get created
    }
}

extension CompetitionUploadManager: CompetitionInteractorDelegate {
    func createdCompetition(_ competition: CompetitionDataModel) {
        /// TODO: created competition. let user know somehow maybe?
    }

    func errorCreatingCompetition(for competitionID: String, _ error: Error) {
        presentError(for: competitionID)
    }
}
