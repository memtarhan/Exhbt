//
//  NewExhbtViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import Photos
import UIKit

class NewExhbtViewModel {
    var model: NewExhbtModel!

    @Published var showCreatedPopup = PassthroughSubject<Int, Never>()
    @Published var eligiblePublisher = PassthroughSubject<Bool, Never>()

    private var cancellables: Set<AnyCancellable> = []

    func checkEligibility() {
        Task {
            do {
                _ = try await model.checkEligibility()
                eligiblePublisher.send(true)

            } catch {
                eligiblePublisher.send(false)
            }
        }
    }

    func create(withAsset asset: CCAsset, tags: [String], description: String, type: ExhbtType) {
        let clearTags = tags.map { $0.removeTagSymbol() }
        Task {
            do {
                let exhbt = try await model.create(withAsset: asset, tags: clearTags, description: description, exhbtType: type)
                self.showCreatedPopup.send(exhbt.id)
            } catch {
                debugLog(self, error)
            }
        }
    }
}

