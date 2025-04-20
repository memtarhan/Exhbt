//
//  MeRealtimeSynchService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 08/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

struct MeRealtimeSyncService {
    func shouldReloadSubmissions() {
        NotificationCenter.default.post(name: .shouldReloadMeSubmissions, object: nil)
    }

    func shouldReloadImage() {
        NotificationCenter.default.post(name: .shouldReloadMeProfilePhoto, object: nil)
    }

    func shouldReloadCoinsCount() {
        NotificationCenter.default.post(name: .shouldReloadMeCoinsCount, object: nil)
    }

    func shouldReloadPrizesCount() {
        NotificationCenter.default.post(name: .shouldReloadMePrizesCount, object: nil)
    }

    func shouldReloadFollowersCount() {
        NotificationCenter.default.post(name: .shouldReloadMeFollowersCount, object: nil)
    }

    func shouldReloadFollowingsCount() {
        NotificationCenter.default.post(name: .shouldReloadMeFollowingsCount, object: nil)
    }

    func shouldReloadInfo() {
        NotificationCenter.default.post(name: .shouldReloadMeInfo, object: nil)
    }
}
