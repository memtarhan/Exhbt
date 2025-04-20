//
//  EventViewModel.swift
//  Exhbt
//
//  Created by Adem Tarhan on 30.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class EventsViewModel: ViewModel {
    var model: EventsModel!

    typealias snapshotType = NSDiffableDataSourceSnapshot<EventsSection, DisplayModel>
    private var snapshot = snapshotType()

    @Published var snapshotPublisher = PassthroughSubject<snapshotType, Never>()
    @Published var shouldPresentDetails = PassthroughSubject<EventDisplayModel, Never>()
    @Published var shouldPresentResult = PassthroughSubject<EventDisplayModel, Never>()
    @Published var shouldDisplayEmptyState = PassthroughSubject<Void, Never>()
    @Published var eligibleToJoinPublisher = PassthroughSubject<Bool, Never>()
    @Published var joinedPublisher = PassthroughSubject<Bool, Never>()

    private var currentPage = 0
    private var searchedKeyword: String?

    private var showNSFWEvents: Bool {
        LocalStorage.shared.showNSFWEvents
    }

    private var showAllEvents: Bool {
        LocalStorage.shared.showAllEvents
    }

    private var sortByLocation: Bool {
        LocalStorage.shared.sortEventsByLocation
    }

    init() {
        snapshot.appendSections(EventsSection.allCases)
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(shouldGetNewEvent), name: .newEventAvailableNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(shouldUpdateEvent), name: .eventUpdateAvailableNotification, object: nil)
    }

    func refresh() {
        currentPage = 0
        snapshot.deleteSections(EventsSection.allCases)
        snapshot.appendSections(EventsSection.allCases)
        load()
    }

    func load() {
        currentPage += 1

//        let models = loadDummyData()
//        snapshot.appendItems(models, toSection: .preview)
//        snapshotPublisher.send(snapshot)
        Task {
            do {
                let events = try await model.get(keyword: searchedKeyword,
                                                 showNSFWContent: showNSFWEvents,
                                                 showAllEvents: showAllEvents,
                                                 sortByLocation: sortByLocation,
                                                 page: currentPage)
                let models = events.map { EventDisplayModel.from(response: $0) }
                snapshot.appendItems(models, toSection: .preview)
                snapshotPublisher.send(snapshot)

                if snapshot.itemIdentifiers(inSection: .preview).isEmpty {
                    shouldDisplayEmptyState.send()
                }

            } catch {
                debugLog(self, error)
            }
        }
    }

    func join(event: EventDisplayModel) {
        Task {
            do {
                let response = try await self.model.checkEligibility()
                eligibleToJoinPublisher.send(response.eligibleToJoinEvent)

                if response.eligibleToJoinEvent {
                    do {
                        try await model.join(eventId: event.id)
                        self.updateJoinStatus(ofEvent: event)
                        self.joinedPublisher.send(true)
                        self.shouldPresentDetails.send(event)

                    } catch {
                        debugLog(self, "Cannot join \(error)")
                        joinedPublisher.send(false)
                    }
                }

            } catch {
                eligibleToJoinPublisher.send(false)
            }
        }
    }

    private func updateJoinStatus(ofEvent event: EventDisplayModel) {
        event.joined = true
        let joinersCount = event.joiners.photos.count + 1
        var title = ""
        var photos = event.joiners.photos
        let newJoinerPhotoURL = UserSettings.shared.profilePhotoThumbnail ?? ""
        photos.append(newJoinerPhotoURL)
        if joinersCount > 3 {
            title = "+\(joinersCount - 3) people joined"

        } else {
            title = "\(joinersCount) people joined"
        }
        event.joiners = EventJoinersDisplayModel(title: title, photos: photos)
        snapshot.reloadItems([event])
        snapshotPublisher.send(snapshot)
    }

    func willDisplayItem(atIndexPath indexPath: IndexPath) {
        if (indexPath.row == snapshot.itemIdentifiers(inSection: .preview).count - 1),
           indexPath.row != 0 {
            // Load more
            load()
        }
    }

    func didSelectItem(atIndexPath indexPath: IndexPath) {
        let event = snapshot.itemIdentifiers(inSection: .preview)[indexPath.row] as! EventDisplayModel
        if event.joined && event.status.status == .live {
            shouldPresentDetails.send(event)

        } else if event.status.status == .finished {
            shouldPresentResult.send(event)
        }
    }
}

// MARK: - Search

extension EventsViewModel: SearchableViewModel {
    func searchBarDidClear() {
        searchedKeyword = nil
        refresh()
    }

    func searchBarDidCancel() {
        searchedKeyword = nil
        refresh()
    }

    func searchBarDidSearch(keyword: String?) {
        guard let keyword else { return }

        searchedKeyword = keyword
        refresh()
    }
}

private extension EventsViewModel {
    @objc
    func shouldGetNewEvent(notification: Notification) {
        if let userInfo = notification.userInfo,
           let eventId = userInfo["eventId"] as? Int {
            Task {
                do {
                    let exhbt = try await model.getSingle(withId: eventId)
                    let displayModel = EventDisplayModel.from(response: exhbt)
                    if let firstItem = snapshot.itemIdentifiers(inSection: .preview).first {
                        snapshot.insertItems([displayModel], beforeItem: firstItem)

                    } else {
                        /// Snapshot is empty
                        snapshot.appendItems([displayModel], toSection: .preview)
                    }
                    snapshotPublisher.send(snapshot)
                } catch {
                    debugLog(self, error)
                }
            }
        }
    }

    @objc
    func shouldUpdateEvent(notification: Notification) {
        if let userInfo = notification.userInfo,
           let eventId = userInfo["eventId"] as? Int {
            Task {
                do {
                    let event = try await model.getSingle(withId: eventId)
                    let displayModel = EventDisplayModel.from(response: event)
                    if let oldExhbt = snapshot.itemIdentifiers(inSection: .preview).first(where: { $0.id == eventId }) {
                        snapshot.insertItems([displayModel], beforeItem: oldExhbt)
                        snapshot.deleteItems([oldExhbt])
                        snapshotPublisher.send(snapshot)
                    }

                } catch {
                    debugLog(self, error)
                }
            }
        }
    }
}

// MARK: - Dummy data

private extension EventsViewModel {
    func loadDummyData() -> [EventDisplayModel] {
        (0 ..< 10).map { id in
            EventDisplayModel(id: id,
                              title: "Dummy Event at #\(id)",
                              description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut laborum",
                              isOwn: Bool.random(),
                              nsfw: Bool.random(),
                              joined: Bool.random(),
                              coverPhoto: "https://images.pexels.com/photos/15839628/pexels-photo-15839628/free-photo-of-a-person-holding-a-coffee-cup.jpeg?auto=compress&cs=tinysrgb&w=1200&lazy=load",
                              photos: ["https://images.pexels.com/photos/15839628/pexels-photo-15839628/free-photo-of-a-person-holding-a-coffee-cup.jpeg?auto=compress&cs=tinysrgb&w=1200&lazy=load"],
                              joiners: EventJoinersDisplayModel(title: "+2 joined", photos: ["https://images.pexels.com/photos/15839628/pexels-photo-15839628/free-photo-of-a-person-holding-a-coffee-cup.jpeg?auto=compress&cs=tinysrgb&w=1200&lazy=load", "https://images.pexels.com/photos/3278327/pexels-photo-3278327.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"]),
                              timeLeft: "\(id)d left",
                              status: EventStatusDisplayModel(status: .live, timeLeft: "2d left"))
        }
    }
}
