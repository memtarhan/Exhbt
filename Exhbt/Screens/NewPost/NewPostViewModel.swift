//
//  NewPostViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 16/10/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Photos
import UIKit

class NewPostViewModel {
    var model: NewPostModel!

    @Published var willDismiss = PassthroughSubject<Void, Error>()
    @Published var eligiblePublisher = PassthroughSubject<Bool, Never>()

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

    func post(withAsset asset: CCAsset, eventId: Int) {
        Task {
            do {
                try await model.post(withAsset: asset, eventId: eventId)
                self.willDismiss.send(completion: .finished)
            } catch {
                self.willDismiss.send(completion: .failure(error))
            }
        }
    }
}
