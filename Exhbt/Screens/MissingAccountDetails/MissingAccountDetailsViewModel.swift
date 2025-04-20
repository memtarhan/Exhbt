//
//  MissingAccountDetailsViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Photos
import UIKit

class MissingAccountDetailsViewModel {
    var model: MissingAccountDetailsModel!

    @Published var shouldNavigateToHome = PassthroughSubject<Void, Never>()
    @Published var failedToUpdateUsername = PassthroughSubject<Void, Never>()

    func createAccount(withAsset asset: CCAsset?, entries: MissingAccountDetailsEntries) {
        Task {
            do {
                let usernameResponse = try await model.save(username: entries.username)

                if usernameResponse.updated {
                    self.save(withAsset: asset, entries: entries)
                    self.shouldNavigateToHome.send()
                } else {
                    // Display alert
                    debugLog(self, "failed to save usernamexxx")
                    failedToUpdateUsername.send()
                }

            } catch {
                debugLog(self, "failed to save username")
                failedToUpdateUsername.send()
            }
        }
    }

    private func save(withAsset asset: CCAsset?, entries: MissingAccountDetailsEntries) {
        Task(priority: .background) {
            _ = try? await self.model.save(fullName: entries.fullName, biography: entries.bio)
            if let asset {
                _ = try? await self.model.saveProfilePhoto(asset: asset)
            }
        }
    }
}
