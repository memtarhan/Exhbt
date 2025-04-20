//
//  GalleryGridViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

typealias gallerySnapshotType = NSDiffableDataSourceSnapshot<GalleryGridSection, GalleryDisplayModel>

class GalleryGridViewModel {
    var model: GalleryGridModel!

    @Published var snapshot = CurrentValueSubject<gallerySnapshotType, Never>(gallerySnapshotType())

    private var page = 0
    private var shouldLoad = true

    var itemsCount: Int {
        snapshot.value.itemIdentifiers(inSection: .main).count
    }

    init() {
        snapshot.value.appendSections(GalleryGridSection.allCases)
    }

    func load() {
        if shouldLoad {
            page += 1

            Task {
                do {
                    let models = try await self.model.get(atPage: page)
                    let displayModels = models.map { GalleryDisplayModel.from(response: $0) }

                    snapshot.value.appendItems(displayModels, toSection: .main)
                    shouldLoad = !models.isEmpty
                } catch {
                    debugLog(self, "failed to fetch submissions")
                }
            }
        }
    }
}
