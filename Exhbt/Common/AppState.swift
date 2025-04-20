//
//  AppState.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import Foundation

class AppState {
    public static let shared = AppState()

    private lazy var userDefaults = UserDefaults.standard

    @Published var invited = CurrentValueSubject<Int?, Never>(LocalStorage.shared.exhbtInvitationId)
    @Published var receivedNotification = PassthroughSubject<Void, Never>()
    @Published var shouldRefreshNotificationsBadgeCount = PassthroughSubject<Void, Never>()
    @Published var shouldShowFlash = PassthroughSubject<Void, Never>()
    @Published var updatedEventFilters = PassthroughSubject<Void, Never>()
    
    var exhbtInvitationId: Int? {
        get {
            debugLog(self, "get exhbtInvitationId")
            return LocalStorage.shared.exhbtInvitationId

        } set {
            debugLog(self, "set exhbtInvitationId")
            LocalStorage.shared.exhbtInvitationId = newValue
        }
    }

    var invitedExhbtId: Int? {
        get {
            debugLog(self, "get invitedExhbtId")
            return LocalStorage.shared.invitedExhbtId

        } set {
            debugLog(self, "set invitedExhbtId")
            LocalStorage.shared.invitedExhbtId = newValue
        }
    }

    func resetInvitation() {
        exhbtInvitationId = nil
        invitedExhbtId = nil
        invited.send(nil)
    }
}
