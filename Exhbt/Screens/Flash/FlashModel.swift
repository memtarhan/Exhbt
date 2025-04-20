//
//  FlashModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/06/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
class FlashModel: ObservableObject {
    @Published var displayModels = [FlashDisplayModel]()
    @Published var isLoading = true
    @Published var result: FlashInteractResult?
    @Published var coinsCount = 0
    @Published var isLoadingCoinsCount = false

    // TODO: Move it to DI?
    private let service: FlashServiceProtocol

    init(service: FlashServiceProtocol = FlashService()) {
        self.service = service

        registerNotifications()
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadCoinsCount), name: .shouldReloadMeCoinsCount, object: nil)
    }

    @objc
    private func shouldReloadCoinsCount() {
        DispatchQueue.main.async {
            self.coinsCount = UserSettings.shared.coinsCount
        }
    }

    private var currentPage = 0

    func load() {
        isLoading = true
        currentPage = 1
        
        Task {
            do {
                isLoadingCoinsCount = true
                let (models, coinsCount) = try await service.get(atPage: currentPage)
                let displayModels = models.enumerated().map { index, value in
                    let videoURL = value.media.video?.url
                    let photoURL = value.media.photo?.large ?? ""

                    return FlashDisplayModel(id: value.id, index: index, url: photoURL, videUrl: videoURL)
                }

                self.displayModels = displayModels
                self.coinsCount = coinsCount
                self.isLoadingCoinsCount = false
                self.isLoading = false
            } catch {
                debugLog(self, error)
                // TODO: Display error
            }
        }
    }

    func loadMore() {
        isLoading = true
        currentPage += 1

        load()
    }

    func interact(_ flash: FlashDisplayModel, interaction: InteractionResponse) {
        isLoadingCoinsCount = true

        Task {
            do {
                let response = try await service.interact(withCompetition: flash.id, interaction: interaction)
                let result = response.result
                self.result = FlashInteractResult(fromResponse: result)
                if result == .win {
                    NotificationCenter.default.post(name: .shouldReloadMeCoinsCount, object: nil)
                }
                self.coinsCount = response.coinsCount
                self.isLoadingCoinsCount = false

            } catch {
                debugLog(self, error)
                // TODO: Present error
            }
        }
    }
}
