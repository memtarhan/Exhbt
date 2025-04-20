//
//  TabBarViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 10/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class TabBarViewModel {
    private let service: InvitationServiceProtocol
    private let meService: MeServiceProtocol

    @Published var shouldShowNewCompetition = PassthroughSubject<Int, Never>()
    @Published var shouldShowAlert = PassthroughSubject<Void, Never>()
    @Published var shouldPresentNotifications = PassthroughSubject<Void, Never>()

    init(service: InvitationServiceProtocol,
         meService: MeServiceProtocol) {
        self.service = service
        self.meService = meService
    }

    private var cancellables: Set<AnyCancellable> = []

    func listenToInvitation() {
        AppState.shared.invited
            .receive(on: DispatchQueue.main)
            .sink { [weak self] invitationId in
                if let invitationId {
                    self?.handleInvitation(withId: invitationId)
                }
            }
            .store(in: &cancellables)
    }

    func listenToNotifications() {
        AppState.shared.receivedNotification
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.shouldPresentNotifications.send()
            }
            .store(in: &cancellables)
    }

    func syncDeviceTokenIfNeeded() {
        if let token = UserSettings.shared.notificationsDeviceToken {
            Task {
                do {
                    _ = try await meService.saveNotificationsDeviceToken(token)
                    UserSettings.shared.hasSyncedNotificationsDeviceToken = true
                } catch {
                    UserSettings.shared.hasSyncedNotificationsDeviceToken = false
                }
            }
        }
    }
}

private extension TabBarViewModel {
    func handleInvitation(withId id: Int) {
        debugLog(self, #function)

        Task {
            do {
                let invitation = try await self.service.getInvitation(withId: id)
                guard invitation.invitedUserId == nil else {
                    AppState.shared.resetInvitation()
                    self.shouldShowAlert.send()

                    return
                }
                if invitation.status == .accepted {
                    AppState.shared.resetInvitation()

                } else {
                    let exhbtId = invitation.exhbtId
                    self.shouldShowNewCompetition.send(exhbtId)
                }

            } catch {
                debugLog(self, "failed to get invitation with id: \(id)")
            }
        }
    }
}
