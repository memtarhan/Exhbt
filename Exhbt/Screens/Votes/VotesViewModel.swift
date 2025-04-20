//
//  VotesViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 20/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class VotesViewModel {
    var model: VotesModel!
    
    typealias snapshotType = NSDiffableDataSourceSnapshot<FeedsSection, FeedPreviewDisplayModel>
    private var snapshot = snapshotType()
    
    @Published var snapshotPublisher = PassthroughSubject<snapshotType, Error>()
    
    var userId: Int?
    
    init() {
        snapshot.appendSections([.main])
    }
    
    func load() {
        Task {
            do {
                let models = try await model.get(forUser: userId)
                let displayModels = models.map {
                    FeedPreviewDisplayModel(id: $0.id,
                                            tag: $0.tags.first ?? "",
                                            description: $0.description,
                                            media: $0.media.map { HorizontalPhotoModel(withResponse: $0) },
                                            voted: $0.voted,
                                            voteCount: $0.voteCount,
                                            expirationDate: $0.dates.expirationDate ?? $0.dates.startDate)
                }
                self.snapshot.appendItems(displayModels, toSection: .main)
                self.snapshotPublisher.send(self.snapshot)
            } catch {
                self.snapshotPublisher.send(completion: .failure(error))
            }
        }
    }
}
