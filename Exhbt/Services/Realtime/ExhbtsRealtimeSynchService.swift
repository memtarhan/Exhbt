//
//  ExhbtsRealtimeSynchService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 08/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

struct ExhbtsRealtimeSyncService {
    func notifyNewExhbtAvailable(exhbtId: Int) {
        NotificationCenter.default.post(name: .newExhbtAvailableNotification, object: nil, userInfo: ["exhbtId": exhbtId])
    }
    
    func notifyExhbtUpdateAvailable(exhbtId: Int) {
        NotificationCenter.default.post(name: .exhbtUpdateAvailableNotification, object: nil, userInfo: ["exhbtId": exhbtId])
    }
}
