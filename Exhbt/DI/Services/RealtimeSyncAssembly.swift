//
//  RealtimeSync.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 01/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import Swinject

class RealtimeSyncAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ExhbtsRealtimeSyncService.self) { _ in
            ExhbtsRealtimeSyncService()
        }

        container.register(EventsRealtimeSyncService.self) { _ in
            EventsRealtimeSyncService()
        }

        container.register(MeRealtimeSyncService.self) { _ in
            MeRealtimeSyncService()
        }
    }
}
