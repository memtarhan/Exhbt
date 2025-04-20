//
//  MeViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 12/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class MeViewModel: ViewModel {
    var model: MeModel!

    typealias snapshotType = NSDiffableDataSourceSnapshot<MeSection, DisplayModel>
    private var snapshot = snapshotType()

    @Published var snapshotPublisher = PassthroughSubject<snapshotType, Error>()
    @Published var shouldNavigateToDetails = PassthroughSubject<ExhbtPreviewDisplayModel, Never>()
    @Published var shouldNavigateToVoting = PassthroughSubject<ExhbtPreviewDisplayModel, Never>()
    @Published var shouldNavigateToResult = PassthroughSubject<ExhbtPreviewDisplayModel, Never>()
    @Published var shouldNavigateToGalleryVertical = PassthroughSubject<(items: [GalleryDisplayModel], selected: Int), Never>()
    @Published var shouldNavigateToEventResult = PassthroughSubject<EventDisplayModel, Never>()
    @Published var shouldNavigateToEventDetails = PassthroughSubject<EventDisplayModel, Never>()

    private var cancellables: Set<AnyCancellable> = []

    private var currentPage = 0
    // TODO: This should be section not index
    var selectedSegmentIndex = 0

    init() {
        snapshot.appendSections([.details, .publicExhbts])
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadSubmissions), name: .shouldReloadMeSubmissions, object: nil)
    }

    func load() {
        loadDetails()
        loadPublicExhbts()
    }

    func willDisplayItem(atIndexPath indexPath: IndexPath) {
        guard let section = MeSection(fromId: selectedSegmentIndex + 1),
              indexPath.row != 0 else { return }

        switch section {
        case .details:
            break
        case .gallery:
            if indexPath.row == snapshot.itemIdentifiers(inSection: .gallery).count - 1 {
                loadGallery()
            }
        case .events:
            if indexPath.row == snapshot.itemIdentifiers(inSection: .events).count - 1 {
                loadEvents()
            }
        case .publicExhbts:
            if indexPath.row == snapshot.itemIdentifiers(inSection: .publicExhbts).count - 1 {
                loadPublicExhbts()
            }
        case .privateExhbts:
            if indexPath.row == snapshot.itemIdentifiers(inSection: .privateExhbts).count - 1 {
                loadPrivateExhbts()
            }
        }
    }

    func didSelectItem(atIndexPath indexPath: IndexPath) {
        guard let section = MeSection(fromId: selectedSegmentIndex + 1) else { return }
        switch section {
        case .details:
            break
        case .gallery:
            if let items = snapshot.itemIdentifiers(inSection: .gallery) as? [GalleryDisplayModel] {
                shouldNavigateToGalleryVertical.send((items, indexPath.row))
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
        case .publicExhbts:
            let exbts = snapshot.itemIdentifiers(inSection: .publicExhbts)
            if exbts.count > indexPath.row {
                if let exhbt = exbts[indexPath.row] as? ExhbtPreviewDisplayModel {
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
        case .privateExhbts:
            let exbts = snapshot.itemIdentifiers(inSection: .privateExhbts)
            if exbts.count > indexPath.row {
                if let exhbt = exbts[indexPath.row] as? ExhbtPreviewDisplayModel {
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
        }
    }

    func refreshAll() {
        refresh()
        loadDetails()
    }

    func refresh() {
        guard let section = MeSection(fromId: selectedSegmentIndex + 1) else { return }
        snapshot.deleteSections([.gallery, .events, .publicExhbts, .privateExhbts])
        currentPage = 0

        switch section {
        case .details:
            break
        case .gallery:
            snapshot.appendSections([.gallery])
            loadGallery()
        case .events:
            snapshot.appendSections([.events])
            loadEvents()
        case .publicExhbts:
            snapshot.appendSections([.publicExhbts])
            loadPublicExhbts()
        case .privateExhbts:
            snapshot.appendSections([.privateExhbts])
            loadPrivateExhbts()
        }
    }

    func loadDetails() {
        if snapshot.sectionIdentifiers.contains(.details) {
            Task {
                do {
                    let response = try await model.getDetails()
                    let tags = try await model.getTags()
                    if snapshot.itemIdentifiers(inSection: .details).isEmpty {
                        let details = ProfileDetailsDisplayModel.from(response: response, tags: tags)
                        snapshot.appendItems([details], toSection: .details)
                    } else {
                        guard let oldDetails = snapshot.itemIdentifiers(inSection: .details)[0] as? ProfileDetailsDisplayModel else { return }
                        oldDetails.update(withResponse: response)
                        snapshot.reloadItems([oldDetails])
                    }
                    snapshotPublisher.send(snapshot)
                } catch {
                    snapshotPublisher.send(completion: .failure(error))
                }
            }
        }
    }

    func loadGallery() {
        currentPage += 1
        Task {
            do {
                let gallery = try await model.getGallery(atPage: currentPage)
                if snapshot.sectionIdentifiers.contains(.gallery) {
                    snapshot.appendItems(gallery, toSection: .gallery)
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
                let events = try await model.getEvents(atPage: currentPage)
                if snapshot.sectionIdentifiers.contains(.events) {
                    snapshot.appendItems(events, toSection: .events)
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
                let exhbts = try await model.getPublicExhbts(atPage: currentPage)
                if snapshot.sectionIdentifiers.contains(.publicExhbts) {
                    snapshot.appendItems(exhbts, toSection: .publicExhbts)
                    snapshotPublisher.send(snapshot)
                }
            } catch {
                snapshotPublisher.send(completion: .failure(error))
            }
        }
    }

    func loadPrivateExhbts() {
        currentPage += 1
        Task {
            do {
                let exhbts = try await model.getPrivateExhbts(atPage: currentPage)
                if snapshot.sectionIdentifiers.contains(.privateExhbts) {
                    snapshot.appendItems(exhbts, toSection: .privateExhbts)
                    snapshotPublisher.send(snapshot)
                }
            } catch {
                snapshotPublisher.send(completion: .failure(error))
            }
        }
    }
}

private extension MeViewModel {
    @objc
    func shouldReloadSubmissions() {
        refresh()
    }
}
