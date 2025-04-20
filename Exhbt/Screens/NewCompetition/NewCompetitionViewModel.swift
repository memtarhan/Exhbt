//
//  NewCompetitionViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/08/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import Photos
import UIKit

class NewCompetitionViewModel {
    var model: NewCompetitionModel!

    @Published var willDismiss = PassthroughSubject<Void, Error>()
    @Published var eligiblePublisher = PassthroughSubject<Bool, Never>()

    var exhbtId: Int?

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

    func create(withAsset asset: CCAsset?, image: UIImage?, type: NewCompetitionType) {
        guard let exhbtId = exhbtId else {
            return
        }

        Task {
            switch type {
            case .new:
                do {
                    try await self.model.create(exhbtId: exhbtId, asset: asset)
                    self.willDismiss.send(completion: .finished)

                } catch {
                    self.willDismiss.send(completion: .failure(error))
                }

            case .join:
                do {
                    try await self.model.joinExhbt(exhbtId: exhbtId, withAsset: asset)
                    self.willDismiss.send(completion: .finished)

                } catch {
                    self.willDismiss.send(completion: .failure(error))
                }

            case .joinWithInvitation:
                if let invitationId = AppState.shared.exhbtInvitationId {
                    do {
                        try await self.model.joinExhbt(exhbtId: exhbtId, withInvitationId: invitationId, withAsset: asset)
                        AppState.shared.resetInvitation()
                        self.willDismiss.send(completion: .finished)

                    } catch {
                        self.willDismiss.send(completion: .failure(error))
                    }

                } else {
                    self.willDismiss.send(completion: .finished)
                }
            }
        }
    }
}
