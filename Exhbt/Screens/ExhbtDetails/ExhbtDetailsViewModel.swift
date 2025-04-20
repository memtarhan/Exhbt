//
//  ExhbtDetailsViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 05/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class ExhbtDetailsViewModel {
    var model: ExhbtDetailsModel!

    @Published var expirationDate = PassthroughSubject<Date, Never>()
    @Published var preview = PassthroughSubject<ExhbtPreviewDisplayModel, Never>()
    @Published var status = PassthroughSubject<SingleExhbtStatusModel, Never>()
    @Published var competitors = PassthroughSubject<SingleExhbtCompetitorsModel, Never>()
    @Published var submissions = PassthroughSubject<SingleExhbtSubmissionsModel, Never>()
    @Published var settings = PassthroughSubject<SingleExhbtSettingsModel, Never>()
    @Published var shouldDisplayError = PassthroughSubject<Void, Never>()
    @Published var deletedExhbt = PassthroughSubject<Void, Never>()

    private var exhbtId: Int?

    func loadData(forExhbt id: Int) {
        exhbtId = id

        Task {
            do {
                let response = try await self.model.getExhbt(withId: id)

                self.expirationDate.send(response.status.status == .submissions ? response.status.startDate : response.status.expirationDate ?? response.status.startDate)
                self.handlePreview(response: response)
                self.handleStatus(response: response)
                self.handleCompetitors(response: response)
                self.handleSubmissions(response: response)
                self.handleSettings(response: response)

            } catch {
                shouldDisplayError.send()
            }
        }
    }

    func delete(exhbt: Int) {
        Task {
            do {
                try await model.deleteExhbt(withId: exhbt)
                deletedExhbt.send()

            } catch {
                deletedExhbt.send()
                shouldDisplayError.send()
            }
        }
    }

    func flag() {
        guard let exhbtId else { return }
        Task {
            await model.flagExhbt(exhbtId)
        }
    }

    private func handlePreview(response: ExhbtDetailsResponse) {
        let model = ExhbtPreviewDisplayModel(id: response.id,
                                             description: response.description,
                                             horizontalModels: response.preview.media.map { HorizontalPhotoModel(withResponse: $0) },
                                             expirationDate: response.status.startDate,
                                             status: ExhbtStatus(fromType: response.status.status),
                                             isOwn: response.canEdit)
        preview.send(model)
    }

    private func handleStatus(response: ExhbtDetailsResponse) {
        let model = SingleExhbtStatusModel(id: response.id,
                                           status: ExhbtStatus(fromType: response.status.status),
                                           remainingDescription: "First \(response.status.remainingCompetitorsCount) users to join will enter",
                                           timeLeft: response.status.status == .submissions ? response.status.startDate.timeLeft : (response.status.expirationDate?.timeLeft ?? response.status.startDate.timeLeft),
                                           canJoin: response.canJoin,
                                           isOwn: response.isOwn)
        status.send(model)
    }

    private func handleCompetitors(response: ExhbtDetailsResponse) {
        let horizontalAccepted = response.competitors.accepted
            .map { SingleExhbtHorizontalCompetitorModel(id: $0.id, photo: $0.photo, accepted: true, isExhbtUser: $0.isExhbtUser) }
        let horizontalPending = response.competitors.pending
            .map { SingleExhbtHorizontalCompetitorModel(id: $0.id, photo: $0.photo, accepted: false, isExhbtUser: $0.isExhbtUser) }

        let verticalAcceptedItems = response.competitors.accepted
            .map { SingleExhbtCompetitorItem(id: $0.id, photo: $0.photo, imageName: nil, name: $0.name, isExhbtUser: $0.isExhbtUser) }
        let verticalAccepted = SingleExhbtVerticalCompetitorModel(sectionTitle: "ACCEPTED", items: verticalAcceptedItems)

        let verticalPendingItems = response.competitors.pending
            .map { SingleExhbtCompetitorItem(id: $0.id, photo: $0.photo, imageName: nil, name: $0.name, isExhbtUser: $0.isExhbtUser) }
        let verticalPending = SingleExhbtVerticalCompetitorModel(sectionTitle: "PENDING", items: verticalPendingItems)

        let startIndex = verticalAccepted.items.count + verticalPending.items.count

        var verticalFreeSpotItems = (0 ..< (response.competitors.freeSpots)).enumerated().map { index, _ in
            SingleExhbtCompetitorItem(id: nil, photo: nil, imageName: "\(startIndex + index + 1)", name: "Free Spot", isExhbtUser: false)
        }

        verticalFreeSpotItems.append(SingleExhbtCompetitorItem(id: nil, photo: nil, imageName: "+", name: "Invite More...", isExhbtUser: false))
        let verticalFreeSpots = SingleExhbtVerticalCompetitorModel(sectionTitle: "FREE SPOTS", items: verticalFreeSpotItems)

        let model = SingleExhbtCompetitorsModel(title: response.competitors.title,
                                                countDescription: response.competitors.countDescription,
                                                horizontalCompetitors: horizontalAccepted + horizontalPending,
                                                verticalCompetitors: [verticalAccepted, verticalPending, verticalFreeSpots],
                                                canJoin: response.canJoin,
                                                isOwn: response.isOwn,
                                                status: ExhbtStatus(fromType: response.status.status))
        competitors.send(model)
    }

    private func handleSubmissions(response: ExhbtDetailsResponse) {
        let model = SingleExhbtSubmissionsModel(title: response.submissions.title,
                                                countDescription: response.submissions.countDescription,
                                                isLocked: response.submissions.isLocked,
                                                submissions: response.submissions.submissions
                                                    .map { SingleExhbtSubmissionModel(photo: $0.photo, voteCount: $0.voteCount) }
        )
        submissions.send(model)
    }

    private func handleSettings(response: ExhbtDetailsResponse) {
        let model = SingleExhbtSettingsModel(isLocked: true)
        settings.send(model)
    }
}
