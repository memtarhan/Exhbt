//
//  HomeViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 02/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class HomeViewModel {
    var model: HomeModel!

    @Published var badgeCount = CurrentValueSubject<Int, Never>(0)

    func loadNotificationsBadgeCount() {
        Task {
            do {
                let response = try await model.getNotificationsBadgeCount()
                self.badgeCount.send(response.count)

            } catch {
                debugLog(self, "loadNotificationsBadgeCount failed")
            }
        }
    }
}
