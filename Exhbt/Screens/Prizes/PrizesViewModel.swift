//
//  PrizesViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 16/01/2024.
//  Copyright © 2024 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class PrizesViewModel {
    var model: PrizesModel!

    typealias snapshotType = NSDiffableDataSourceSnapshot<PrizeSection, DisplayModel>
    private var snapshot = snapshotType()

    @Published var snapshotPublisher = PassthroughSubject<snapshotType, Error>()
    @Published var shouldNavigateToResult = PassthroughSubject<Int, Never>()

    var userId: Int?

    init() {
        snapshot.appendSections([.main])
    }

    func load() {
        Task {
            do {
                let prizes = try await model.getPrizes(forUserId: userId)
                let models = prizes.map { PrizeDisplayModel.from(response: $0) }
                if snapshot.sectionIdentifiers.contains(.main) {
                    snapshot.appendItems(models, toSection: .main)
                    snapshotPublisher.send(snapshot)
                }
            } catch {
                snapshotPublisher.send(completion: .failure(error))
            }
        }
    }

    func didSelectItem(atIndexPath indexPath: IndexPath) {
        let prizes = snapshot.itemIdentifiers(inSection: .main)
        let prize = prizes[indexPath.row] as! PrizeDisplayModel
        shouldNavigateToResult.send(prize.exhbtId)
    }
}
