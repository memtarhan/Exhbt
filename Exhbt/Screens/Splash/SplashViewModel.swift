//
//  SplashViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class SplashViewModel {
    var model: SplashModel!

    @Published var fetchedInitialData = PassthroughSubject<Void, Error>()
    @Published var shouldDisplayMissingDetails = PassthroughSubject<Void, Never>()

    func triggerDataFetch() {
        Task {
            do {
                let response = try await model.fetchProfileData()
                if response.missingDetails {
                    shouldDisplayMissingDetails.send()
                } else {
                    fetchedInitialData.send(completion: .finished)
                }
            } catch {
                fetchedInitialData.send(completion: .failure(error))
            }
        }
    }
}
