//
//  ExhbtContentViewModel.swift
//  Exhbt
//
//  Created by Adem Tarhan on 19.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Foundation
import UIKit

class ExhbtContentViewModel {
    var model: ExhbtContentModel!
    var exhbtModel: ExhbtPreviewDisplayModel!

    typealias snapshotType = NSDiffableDataSourceSnapshot<ExhbtContentSection, ExhbtContentDisplayModel>
    private var snapshot = snapshotType()
    lazy var sections = ExhbtContentSection.allCases

    @Published var snapshotPublisher = PassthroughSubject<snapshotType, Never>()
    @Published var didSelectItem = PassthroughSubject<Int, Never>()

    private var currentPage = 0

    init() {
        snapshot.appendSections(sections)
    }

    func load() {
        guard let exhbtModel else { return }
        let fullItems = exhbtModel.horizontalModels.map {
            ExhbtContentDisplayModel(id: exhbtModel.id, url: $0.url, videoURL: $0.videoURL)
        }
        snapshot.appendItems(fullItems, toSection: .full)

        let thumbnailItems = exhbtModel.horizontalModels.map {
            ExhbtContentDisplayModel(id: exhbtModel.id, url: $0.url, videoURL: nil)
        }
        snapshot.appendItems(thumbnailItems, toSection: .thumbnail)
        snapshotPublisher.send(snapshot)
        didSelectItem.send(0)
    }

    // MARK: when changed in thumbnail view

    func didSelectItem(atIndexPath indexPath: IndexPath) {
        if indexPath.row != currentPage {
            didSelectItem.send(indexPath.row)
            currentPage = indexPath.row
            debugLog(self, "currentPage: \(currentPage)")
        }
    }

    // MARK: when changed in full image view

    func didSelectItem(atPage page: Int) {
        if page != currentPage {
            didSelectItem.send(page)
            currentPage = page
            debugLog(self, "currentPage: \(currentPage)")
        }
    }
}
