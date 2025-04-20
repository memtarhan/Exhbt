//
//  SigninViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 19/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class SigninViewModel {
    var model: SigninModel!

    @Published var willNavigateToHome = PassthroughSubject<Void, Never>()
    @Published var willNavigateToMissingDetails = PassthroughSubject<Void, Never>()

    func signin(withIdentifier identifier: String) {
        Task {
            do {
                let response = try await self.model.signin(withIdentifier: identifier)
                if response.missingDetails {
                    self.willNavigateToMissingDetails.send()
                } else {
                    self.willNavigateToHome.send()
                }

            } catch {
                debugLog(self, error)
            }
        }
    }
}
