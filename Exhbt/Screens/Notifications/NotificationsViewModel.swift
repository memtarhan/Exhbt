//
//  NotificationsViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class NotificationsViewModel {
    var model: NotificationsModel!

    typealias snapshotType = NSDiffableDataSourceSnapshot<NotificationSection, NotificationDisplayModel>
    private var snapshot = snapshotType()

    @Published var snapshotPublisher = PassthroughSubject<snapshotType, Never>()
    @Published var shouldDisplayEmptyState = PassthroughSubject<Void, Never>()
    @Published var willPresentUser = PassthroughSubject<Int, Never>()
    @Published var willPresentExhbtDetails = PassthroughSubject<Int, Never>()
    @Published var willPresentExhbtResult = PassthroughSubject<Int, Never>()
    @Published var willPresentJoinExhbt = PassthroughSubject<Int, Never>()
    @Published var willPresentJoinEvent = PassthroughSubject<Int, Never>()
    @Published var willPresentEventResult = PassthroughSubject<Int, Never>()
    @Published var joinedPublisher = PassthroughSubject<(Bool, eventId: Int), Never>()
    @Published var eligibleToJoinPublisher = PassthroughSubject<Bool, Never>()

    private var currentPage = 0

    init() {
        snapshot.appendSections([.main])
    }

    func load() {
        currentPage += 1
        handleNotifications(atPage: currentPage)
    }

    func markAllAsRead() {
        let data = snapshot.itemIdentifiers(inSection: .main)
        data.forEach {
            _ = $0.read()
        }
        snapshot.reloadItems(data)
        snapshotPublisher.send(snapshot)
    }

    func didSelectItem(atIndexPath indexPath: IndexPath) {
        guard indexPath.row < snapshot.itemIdentifiers(inSection: .main).count else { return }
        let data = snapshot.itemIdentifiers(inSection: .main)[indexPath.row]

        if data.read() {
            snapshot.reloadItems([data])
            snapshotPublisher.send(snapshot)

            Task(priority: .background) {
                try? await model.read(withId: data.id)
            }
        }

        if data.type == .newFollower,
           let userId = data.getUserId() {
            willPresentUser.send(userId)

        } else if data.type == .competitorJoined,
                  let exhbtId = data.getExhbtId() {
            willPresentExhbtDetails.send(exhbtId)

        } else if data.type == .exhbtStarted,
                  let exhbtId = data.getExhbtId() {
            debugLog(self, "exhbtStarted : \(exhbtId)")

        } else if data.type == .exhbtFinished,
                  let exhbtId = data.getExhbtId() {
            willPresentExhbtResult.send(exhbtId)

        } else if data.type == .invitation,
                  let exhbtId = data.getExhbtId() {
            willPresentExhbtDetails.send(exhbtId)

        } else if data.type == .invitationToEvent,
                  let eventId = data.getEventId() {
            willPresentJoinEvent.send(eventId)

        } else if data.type == .eventFinished,
                  let eventId = data.getEventId() {
            willPresentEventResult.send(eventId)
        }
    }

    func willDisplayItem(atIndexPath indexPath: IndexPath) {
        if indexPath.row == snapshot.itemIdentifiers(inSection: .main).count - 1 {
            load()
        }
    }

    func joinEvent(withId id: Int) {
        Task {
            do {
                let response = try await self.model.checkEligibility()
                eligibleToJoinPublisher.send(response.eligibleToJoinEvent)

                if response.eligibleToJoinEvent {
                    do {
                        try await model.join(eventId: id)
                        self.joinedPublisher.send((true, id))

                    } catch {
                        debugLog(self, "Cannot join \(error)")
                        joinedPublisher.send((false, id))
                    }
                }

            } catch {
                eligibleToJoinPublisher.send(false)
            }
        }
    }

    private func handleNotifications(atPage page: Int) {
        Task {
            do {
                let models = try await model.get(atPage: page)

                if models.isEmpty && snapshot.itemIdentifiers(inSection: .main).isEmpty {
                    shouldDisplayEmptyState.send()

                } else {
                    let displayModels = models.map { NotificationDisplayModel.from(response: $0) }
                    self.snapshot.appendItems(displayModels, toSection: .main)
                    snapshotPublisher.send(snapshot)
                }

            } catch {
                debugLog(self, error)
                shouldDisplayEmptyState.send()
            }
        }
    }
}
