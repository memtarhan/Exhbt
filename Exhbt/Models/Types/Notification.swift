//
//  Notification.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 22/12/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

enum NotificationType: String, Codable {
    case newFollower
    case exhbtStarted
    case exhbtFinished
    case exhbtArchived
    case competitorJoined
    case invitation
    case invitationToEvent
    case eventFinished
}
