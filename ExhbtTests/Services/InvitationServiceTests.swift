//
//  InvitationServiceTests.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 11/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

@testable import Exhbt
import XCTest

final class InvitationServiceTests: XCTestCase {
    private var service: InvitationServiceProtocol!

    override func setUpWithError() throws {
        service = StubInvitationService()
    }

    func testInvitationResponseDecoding() async throws {
        _ = try await service.getInvitation(withId: 12)
    }
    
    func testAcceptInvitation() async throws {
        _ = try await service.acceptInvitation(withId: 9)
    }
}
