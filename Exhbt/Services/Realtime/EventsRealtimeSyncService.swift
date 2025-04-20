//
//  EventsRealtimeSyncService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 02/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

struct EventsRealtimeSyncService {
    func notifyNewEventAvailable(eventId: Int) {
        NotificationCenter.default.post(name: .newEventAvailableNotification, object: nil, userInfo: ["eventId": eventId])
    }
    
    func notifyEventUpdateAvailable(eventId: Int) {
        NotificationCenter.default.post(name: .eventUpdateAvailableNotification, object: nil, userInfo: ["eventId": eventId])
    }
}
