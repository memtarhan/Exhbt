//
//  EventViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 02/01/2024.
//  Copyright © 2024 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class EventViewModel {
    var model: EventModel!

    @Published var eventPublisher = PassthroughSubject<EventDisplayModel, Never>()
    @Published var eligibleToJoinPublisher = PassthroughSubject<Bool, Never>()
    @Published var joinedPublisher = PassthroughSubject<Bool, Never>()
    @Published var shouldPresentDetails = PassthroughSubject<EventDisplayModel, Never>()

    var eventId: Int?

    func load() {
        guard let eventId else { return }

        Task {
            do {
                let response = try await model.getSingle(withId: eventId)
                let event = EventDisplayModel.from(response: response)
                self.eventPublisher.send(event)

            } catch {
                debugLog(self, error.localizedDescription)
            }
        }
    }

    func join() {
        guard let eventId else { return }

        Task {
            do {
                let response = try await self.model.checkEligibility()
                eligibleToJoinPublisher.send(response.eligibleToJoinEvent)

                if response.eligibleToJoinEvent {
                    do {
                        let response = try await model.join(eventId: eventId)
                        let event = EventDisplayModel.from(response: response)
                        self.eventPublisher.send(event)
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
}
