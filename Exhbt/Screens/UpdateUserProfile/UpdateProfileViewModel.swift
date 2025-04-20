//
//  UpdateProfileViewModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 23/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Foundation

class UpdateProfileViewModel {
    var model: UpdateProfileModel!

    @Published var updated = PassthroughSubject<(updated: Bool, status: String?), Never>()
    @Published var status = PassthroughSubject<String, Never>()

    private var cancellables: Set<AnyCancellable> = []

    func update(forFieldType type: UpdateProfileFieldType, value: String?) {
        switch type {
        case .username:
            guard let username = value else { return }
            let trueUsername = username
                .replacingOccurrences(of: " ", with: "")
                .lowercased()
            update(username: trueUsername)

        case .fullName:
            guard let fullName = value else { return }
            update(fullName: fullName)

        case .bio:
            guard let bio = value else { return }
            update(bio: bio)
        }
    }

    private func update(username: String) {
        Task {
            do {
                let response = try await self.model.update(username: username)
                self.updated.send((updated: response.updated, status: response.updated ? "Successfully updated" : response.response))

            } catch {
                self.updated.send((updated: false, status: error.localizedDescription))
            }
        }
    }

    private func update(fullName: String) {
        Task {
            do {
                _ = try await self.model.update(fullName: fullName, biography: nil, voteStyle: nil)
                self.updated.send((updated: true, status: "Successfully updated"))

            } catch {
                self.updated.send((updated: false, status: error.localizedDescription))
            }
        }
    }

    private func update(bio: String) {
        Task {
            do {
                _ = try await self.model.update(fullName: nil, biography: bio, voteStyle: nil)
                self.updated.send((updated: true, status: "Successfully updated"))

            } catch {
                self.updated.send((updated: false, status: error.localizedDescription))
            }
        }
    }
}
