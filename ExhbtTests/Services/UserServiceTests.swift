//
//  UserServiceTests.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 29/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import XCTest
@testable import Exhbt

final class UserServiceTests: XCTestCase {

    private var service: UserServiceProtocol!
    
    override func setUpWithError() throws {
        service = StubUserService()
    }

    func testFetchProfileDetailsDecoding() async throws {
        _ = try await service.getProfileDetails(withId: 38)
    }

}
