//
//  UserViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 13/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class UserViewModel {
    var model: UserModel!

    typealias snapshotType = NSDiffableDataSourceSnapshot<UserSection, DisplayModel>
    private var snapshot = snapshotType()

    @Published var usernamePublisher = PassthroughSubject<String, Never>()
    @Published var snapshotPublisher = PassthroughSubject<snapshotType, Error>()
    @Published var shouldNavigateToDetails = PassthroughSubject<ExhbtPreviewDisplayModel, Never>()
    @Published var shouldNavigateToVoting = PassthroughSubject<ExhbtPreviewDisplayModel, Never>()
    @Published var shouldNavigateToResult = PassthroughSubject<ExhbtPreviewDisplayModel, Never>()
    @Published var shouldNavigateToGalleryVertical = PassthroughSubject<(items: [GalleryDisplayModel], selected: Int), Never>()
    @Published var shouldNavigateToEventResult = PassthroughSubject<EventDisplayModel, Never>()
    @Published var shouldNavigateToEventDetails = PassthroughSubject<EventDisplayModel, Never>()
    
    private var currentPage = 0
    var selectedSegmentIndex = 0

    var userId: Int!

    init() {
        snapshot.appendSections([.details, .publicExhbts])
    }

    func willDisplayItem(atIndexPath indexPath: IndexPath) {
        guard let section = UserSection(fromId: selectedSegmentIndex + 1) else { return }
        switch section {
        case .details:
            break
        case .gallery:
            if indexPath.row == snapshot.itemIdentifiers(inSection: .gallery).count - 1 {
                loadGallery()
            }
        case .publicExhbts:
            if indexPath.row == snapshot.itemIdentifiers(inSection: .publicExhbts).count - 1 {
                loadPublicExhbts()
            }
        case .events:
            if indexPath.row == snapshot.itemIdentifiers(inSection: .events).count - 1 {
                loadEvents()
            }
        }
    }

    func didSelectItem(atIndexPath indexPath: IndexPath) {
        guard let section = UserSection(fromId: selectedSegmentIndex + 1) else { return }

        switch section {
        case .details:
            break
        case .gallery:
            if let items = snapshot.itemIdentifiers(inSection: .gallery) as? [GalleryDisplayModel] {
                shouldNavigateToGalleryVertical.send((items, indexPath.row))
            }
        case .publicExhbts:
            let exhbts = snapshot.itemIdentifiers(inSection: .publicExhbts)
            if exhbts.count > indexPath.row {
                if let exhbt = exhbts[indexPath.row] as? ExhbtPreviewDisplayModel {
                    switch exhbt.status {
                    case .finished:
                        shouldNavigateToResult.send(exhbt)
                    case .live:
                        shouldNavigateToVoting.send(exhbt)
                    case .submissions, .archived:
                        shouldNavigateToDetails.send(exhbt)
                    }
                }
            }
        case .events:
            let events = snapshot.itemIdentifiers(inSection: .events)
            if events.count > indexPath.row {
                if let event = events[indexPath.row] as? EventDisplayModel {
                    switch event.status.status {
                    case .finished:
                        shouldNavigateToEventResult.send(event)
                    case .live:
                        shouldNavigateToEventDetails.send(event)
                    }
                }
            }
        }
    }

    func refresh() {
        guard let section = UserSection(fromId: selectedSegmentIndex + 1) else { return }
        snapshot.deleteSections([.gallery, .publicExhbts, .events])
        currentPage = 0
        switch section {
        case .details:
            break
        case .gallery:
            snapshot.appendSections([.gallery])
            loadGallery()
        case .publicExhbts:
            snapshot.appendSections([.publicExhbts])
            loadPublicExhbts()
        case .events:
            snapshot.appendSections([.events])
            loadEvents()
        }
    }

    func loadDetails() {
        Task {
            do {
                let details = try await model.getDetails(withId: userId)
                usernamePublisher.send(details.username)
                if snapshot.sectionIdentifiers.contains(.details) {
                    snapshot.appendItems([details], toSection: .details)
                    snapshotPublisher.send(snapshot)
                }
            } catch {
                snapshotPublisher.send(completion: .failure(error))
            }
        }
    }

    func loadGallery() {
        currentPage += 1
        Task {
            do {
                let gallery = try await model.getGallery(withId: userId, atPage: currentPage)
                if snapshot.sectionIdentifiers.contains(.gallery) {
                    snapshot.appendItems(gallery, toSection: .gallery)
                    snapshotPublisher.send(snapshot)
                }
            } catch {
                snapshotPublisher.send(completion: .failure(error))
            }
        }
    }

    func loadPublicExhbts() {
        currentPage += 1
        Task {
            do {
                let exhbts = try await model.getPublicExhbts(withId: userId, atPage: currentPage)
                if snapshot.sectionIdentifiers.contains(.publicExhbts) {
                    snapshot.appendItems(exhbts, toSection: .publicExhbts)
                    snapshotPublisher.send(snapshot)
                }
            } catch {
                snapshotPublisher.send(completion: .failure(error))
            }
        }
    }

    func loadEvents() {
        currentPage += 1

        if snapshot.sectionIdentifiers.contains(.events) {
            snapshot.appendItems([], toSection: .events)
            snapshotPublisher.send(snapshot)
        }

        Task {
            do {
                let events = try await model.getEvents(withId: userId, atPage: currentPage)
                if snapshot.sectionIdentifiers.contains(.events) {
                    snapshot.appendItems(events, toSection: .events)
                    snapshotPublisher.send(snapshot)
                }
            } catch {
                snapshotPublisher.send(completion: .failure(error))
            }
        }
    }

    func willUpdateFollow(_ user: ProfileDetailsDisplayModel) {
        guard user.id == userId else { return }
        if !snapshot.itemIdentifiers(inSection: .details).isEmpty {
            let details = snapshot.itemIdentifiers(inSection: .details)[0] as! ProfileDetailsDisplayModel
            Task(priority: .background) {
                if details.followingStatus == .following {
                    try await model.folllowUser(withId: userId)
                } else {
                    try await model.unfollowUser(withId: userId)
                }
            }
            details.followingStatus.toggle()
            snapshot.reloadItems([details])
            snapshotPublisher.send(snapshot)
        }
    }
}
