//
//  ExploreViewModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 25/03/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class ExhbtsViewModel: ViewModel {
    var model: ExhbtsModel!

    typealias snapshotType = NSDiffableDataSourceSnapshot<ExhbtsSection, DisplayModel>
    var snapshot = snapshotType()

    @Published var reloadTags = PassthroughSubject<Void, Never>()
    @Published var reloadExhbts = PassthroughSubject<Void, Never>()
    @Published var shouldNavigateToDetails = PassthroughSubject<ExhbtPreviewDisplayModel, Never>()
    @Published var shouldShowError = PassthroughSubject<Void, Never>()
    @Published var shouldDisplayEmptyState = PassthroughSubject<Void, Never>()

    private var page = 0
    var selectedTag: TagDisplayModel?

    var searchedKeyword: String?

    private var cancellables: Set<AnyCancellable> = []

    init() {
        snapshot.appendSections(ExhbtsSection.allCases)
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(shouldGetNewExhbt), name: .newExhbtAvailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldUpdateExhbt), name: .exhbtUpdateAvailableNotification, object: nil)
    }

    func load() {
        loadTags()
        loadExhbts()
    }

    func loadTags() {
        Task {
            do {
                let tags = try await model.getPopularTags()
                let models = tags.map { TagDisplayModel(id: $0.id, title: $0.label) }
                let model = TagsDisplayModel(id: 1, tags: models)
                snapshot.appendItems([model], toSection: .tags)
                reloadTags.send()
            } catch {
                debugLog(self, error.localizedDescription)
            }
        }
    }

    func willDisplayItem(atIndexPath indexPath: IndexPath) {
        if let section = ExhbtsSection(fromId: indexPath.section) {
            switch section {
            case .tags:
                break
            case .exhbts:
                if indexPath.row == snapshot.itemIdentifiers(inSection: section).count - 1 {
                    loadExhbts()
                }
            }
        }
    }

    func didSelectItem(atIndexPath indexPath: IndexPath) {
        if let section = ExhbtsSection(fromId: indexPath.section) {
            switch section {
            case .exhbts:
                let exhbts = snapshot.itemIdentifiers(inSection: .exhbts)
                if exhbts.count > indexPath.row {
                    if let exhbt = exhbts[indexPath.row] as? ExhbtPreviewDisplayModel {
                        shouldNavigateToDetails.send(exhbt)
                    }
                }
            case .tags:
                /// Will be implemented
                let tags = snapshot.itemIdentifiers(inSection: .tags)
                if tags.count > indexPath.row {
                    if let tag = tags[indexPath.row] as? TagDisplayModel {
                        selectedTag = tag
                    }
                }
            }
        }
    }

    func refresh() {
        page = 0
//        reloadExhbts.send()
        loadExhbts(true)
    }

    func loadExhbts(_ isRefreshed: Bool = false) {
        page += 1
        Task {
            do {
                let models = try await model.get(forTag: selectedTag?.title, title: searchedKeyword, page: page)
                if isRefreshed {
                    snapshot.deleteSections([.exhbts])
                    snapshot.appendSections([.exhbts])
                    let displayModels = createDisplayModels(models)
                    snapshot.appendItems(displayModels, toSection: .exhbts)
                    reloadExhbts.send()

                } else {
                    if !models.isEmpty {
                        let displayModels = createDisplayModels(models)
                        snapshot.appendItems(displayModels, toSection: .exhbts)
                        reloadExhbts.send()

                    } else if snapshot.itemIdentifiers(inSection: .exhbts).isEmpty {
                        self.shouldDisplayEmptyState.send()
                    }
                }

            } catch {
                debugLog(self, error.localizedDescription)
            }
        }
    }
}

// MARK: - Search

extension ExhbtsViewModel: SearchableViewModel {
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

private extension ExhbtsViewModel {
    func createDisplayModels(_ models: [ExhbtPreviewResponse]) -> [ExhbtPreviewDisplayModel] {
        models.map {
            ExhbtPreviewDisplayModel(id: $0.id,
                                     description: $0.description,
                                     horizontalModels: $0.media.map { HorizontalPhotoModel(withResponse: $0) },
                                     expirationDate: $0.dates.startDate,
                                     status: ExhbtStatus(fromType: $0.status),
                                     isOwn: $0.isOwn)
        }
    }
}

private extension ExhbtsViewModel {
    @objc
    func shouldGetNewExhbt(notification: Notification) {
        if let userInfo = notification.userInfo,
           let exhbtId = userInfo["exhbtId"] as? Int {
            Task {
                do {
                    let exhbt = try await model.getSingle(withId: exhbtId)
                    let displayModel = ExhbtPreviewDisplayModel.from(response: exhbt)
                    if let firstItem = snapshot.itemIdentifiers(inSection: .exhbts).first {
                        snapshot.insertItems([displayModel], beforeItem: firstItem)

                    } else {
                        /// Snapshot is empty
                        snapshot.appendItems([displayModel], toSection: .exhbts)
                    }
                    reloadExhbts.send()
                } catch {
                    debugLog(self, error)
                }
            }
        }
    }

    @objc
    func shouldUpdateExhbt(notification: Notification) {
        if let userInfo = notification.userInfo,
           let exhbtId = userInfo["exhbtId"] as? Int {
            Task {
                do {
                    let exhbt = try await model.getSingle(withId: exhbtId)
                    let displayModel = ExhbtPreviewDisplayModel.from(response: exhbt)
                    if let oldExhbt = snapshot.itemIdentifiers(inSection: .exhbts).first(where: { $0.id == exhbtId }) {
                        snapshot.insertItems([displayModel], beforeItem: oldExhbt)
                        snapshot.deleteItems([oldExhbt])
                        reloadExhbts.send()
                    }

                } catch {
                    debugLog(self, error)
                }
            }
        }
    }
}
