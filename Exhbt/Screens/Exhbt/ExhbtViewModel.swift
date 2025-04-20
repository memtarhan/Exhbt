//
//  ExhbtViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 29/08/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class ExhbtViewModel {
    var model: ExhbtModel!

    @Published var title = PassthroughSubject<String, Never>()
    @Published var media = PassthroughSubject<(content: [HorizontalPhotoModel], exhbtId: Int), Never>()
    @Published var category = PassthroughSubject<String, Never>()
    @Published var timeLeft = PassthroughSubject<String, Never>()
    @Published var status = PassthroughSubject<ExhbtStatus, Never>()
    @Published var exhbtStatus = PassthroughSubject<ExhbtStatusDisplayModel, Never>()

    private var cancellables: Set<AnyCancellable> = []
    private var exhbtId: Int?

    func loadData(forExhbt id: Int) {
        exhbtId = id

        Task {
            guard let model = try? await self.model.fetchExhbt(withId: id) else { return }

            self.title.send("Exhbt")

            let media = model.competitions.map { HorizontalPhotoModel(withDisplayModel: $0.media) }
            self.media.send((media, model.id))

//            self.images.send((images: images, thumbnails: thumbnails, model.id))

//            self.category.send(model.category.uppercased())

            let expirationDate = model.createdAt.advanced(by: 2 * 24 * 60 * 60)
            var status = ExhbtStatus.submissions
            let isPassed = expirationDate.timeIntervalSince(Date()) > 0
            if isPassed {
                status = .submissions

            } else {
                status = .finished
            }

            self.timeLeft.send(expirationDate.timeLeft)
            self.status.send(status)

            let titleString = status == .live ? "Exhbt is live" : "Competitors Joining"
            let font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            let attributes = [NSAttributedString.Key.font: font]
            let attributedQuote = NSMutableAttributedString(string: titleString, attributes: attributes)

            if status == .live {
                attributedQuote.addAttribute(.foregroundColor, value: UIColor.systemRed, range: NSRange(location: 9, length: 4))
            }

            self.exhbtStatus.send(ExhbtStatusDisplayModel(title: attributedQuote,
                                                          timeLeft: expirationDate.timeLeft,
                                                          countDetails: "First 7􀉪 to join will enter the exhbt",
                                                          status: status))
        }
    }
    
    func flag() {
        guard let exhbtId else { return }
        Task {
            await model.flagExhbt(exhbtId)
        }
    }
}
