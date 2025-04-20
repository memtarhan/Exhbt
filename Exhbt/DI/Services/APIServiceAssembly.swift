//
//  APIServiceAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 24/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation
import Swinject

class APIServiceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AuthServiceProtocol.self) { resolver in
            AuthService(userService: resolver.resolve(ProfileServiceProtocol.self)!)
        }

        container.register(CompetitionServiceProtocol.self) { resolver in
            CompetitionService(uploadService: resolver.resolve(UploadServiceProtocol.self)!)
        }

        container.register(ExhbtServiceProtocol.self) { resolver in
            ExhbtService(uploadService: resolver.resolve(UploadServiceProtocol.self)!,
                         meService: resolver.resolve(MeServiceProtocol.self)!)
        }

        container.register(ExhbtsServiceProtocol.self) { _ in
            ExhbtsService()
        }

        container.register(EventServiceProtocol.self) { resolver in
            EventService(uploadService: resolver.resolve(UploadServiceProtocol.self)!, 
                         meService: resolver.resolve(MeServiceProtocol.self)!,
                         realtimeSync: resolver.resolve(EventsRealtimeSyncService.self)!)
        }

        container.register(FeedsServiceProtocol.self) { _ in
            FeedsService()
        }

        container.register(InvitationServiceProtocol.self) { _ in
            InvitationService()
        }

        container.register(LeaderboardServiceProtocol.self) { _ in
            LeaderboardService()
        }

        container.register(MeServiceProtocol.self) { _ in
            MeService()
        }

        container.register(ProfileServiceProtocol.self) { _ in
            ProfileService()
        }

        container.register(ServerServiceProtocol.self) { _ in
            ServerService()
        }

        container.register(UploadServiceProtocol.self) { _ in
            UploadService()
        }

        container.register(UserServiceProtocol.self) { _ in
            UserService()
        }

        container.register(TagServiceProtocol.self) { _ in
            TagService()
        }
        
        container.register(PostsServiceProtocol.self) { resolver in
            PostsService(realtimeSync: resolver.resolve(EventsRealtimeSyncService.self)!)
        }
    }
}
