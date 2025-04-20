//
//  NewEventViewModel.swift
//  Exhbt
//
//  Created by Adem Tarhan on 29.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Photos
import UIKit

class NewEventViewModel {
    var model: NewEventModel!

    @Published var dismissPublisher = PassthroughSubject<Void, Never>()
    @Published var eligiblePublisher = PassthroughSubject<Bool, Never>()
    @Published var enablePublisher = PassthroughSubject<Bool, Never>()

    var eventTitle: String? {
        didSet {
            validate()
        }
    }

    var eventDescription: String? {
        didSet {
            validate()
        }
    }

    var eventCoverAsset: CCAsset? {
        didSet {
            validate()
        }
    }

    var eventDurationInDays: Int = 2 {
        didSet {
            validate()
        }
    }

    var eventType: EventType? {
        didSet {
            validate()
        }
    }

    var eventIsNSFW: Bool = false {
        didSet {
            validate()
        }
    }

    var eventAddress: AddressModel? {
        didSet {
            validate()
        }
    }

    private var requestModel: NewEventRequestModel?

    func checkEligibility() {
        Task {
            do {
                let response = try await self.model.checkEligibility()
                eligiblePublisher.send(response.eligibleToCreateEvent)

            } catch {
                eligiblePublisher.send(false)
            }
        }
    }

    func create() {
        guard let requestModel else { return }
        enablePublisher.send(false)
        Task {
            do {
                try await model.create(withRequest: requestModel)
                dismissPublisher.send()

            } catch {
                debugLog(self, error)
                // TODO: Display error
            }
        }
    }
}

private extension NewEventViewModel {
    func validate() {
        if let eventTitle,
           !eventTitle.isEmpty,
           let eventDescription,
           !eventDescription.isEmpty,
           let eventCoverAsset,
           let eventType,
           let eventAddress {
            enablePublisher.send(true)
            requestModel = NewEventRequestModel(title: eventTitle,
                                                description: eventDescription,
                                                coverAsset: eventCoverAsset,
                                                durationInDays: eventDurationInDays,
                                                type: eventType,
                                                isNSFW: eventIsNSFW,
                                                address: eventAddress)
        } else {
            enablePublisher.send(false)
        }
    }
}
