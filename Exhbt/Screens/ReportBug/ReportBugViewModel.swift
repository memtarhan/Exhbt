//
//  ReportBugViewModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 10/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Photos
import UIKit

class ReportBugViewModel {
    var model: ReportBugModel!
    var view: ReportBugViewController!
    @Published var addedAsset = CurrentValueSubject<PHAsset?, Never>(nil)
    @Published var addedImage = CurrentValueSubject<UIImage?, Never>(nil)
    @Published var snapshot = CurrentValueSubject<snapshotType, Never>(snapshotType())

    typealias snapshotType = NSDiffableDataSourceSnapshot<ReportSection, ReportScreenshotDisplayModel>
    var cancellables: Set<AnyCancellable> = []
    fileprivate let imageManager = PHCachingImageManager()

    init() {
        snapshot.value.appendSections([.screenshot])
        addedAsset
            .receive(on: DispatchQueue.main)
            .sink { [weak self] asset in
                guard let self = self,
                      let asset = asset else { return }
                let requestOptions = PHImageRequestOptions()
                requestOptions.deliveryMode = .highQualityFormat
                requestOptions.isSynchronous = false
                self.imageManager.requestImage(
                    for: asset,
                    targetSize: self.view.view.frame.size,
                    contentMode: .aspectFill,
                    options: requestOptions,
                    resultHandler: { [weak self] image, _ in
                        guard let self = self, let image = image else { return }
                        self.imageData(image: image)
                    })
            }
            .store(in: &cancellables)
        addedImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self,
                      let image = image else { return }
                debugLog(self, "Image has arrived: ", image)
            }
            .store(in: &cancellables)
    }

    func imageData(image: UIImage) {
        let randomFourDigitNumber = Int.random(in: 1000 ..< 10000)
        let imageName = "IMG_\(randomFourDigitNumber).PNG"
        let size = bytesToHumanReadableString(bytes: image.pngData()?.count ?? 0)
        let display = ReportScreenshotDisplayModel()
        display.name = imageName
        display.size = size
        display.image = image
        snapshot.value.appendItems([display], toSection: .screenshot)
        snapshot.send(snapshot.value)
    }

    func bytesToHumanReadableString(bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
