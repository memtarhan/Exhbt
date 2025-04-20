//
//  LeaderboardServiceTests.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 28/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

@testable import Exhbt
import XCTest

final class LeaderboardServiceTests: XCTestCase {
    private var service: LeaderboardServiceProtocol!

    override func setUpWithError() throws {
        service = StubLeaderboardService()
    }

    func testFetchLeaderboardDecoding() async throws {
        let category = Category.all
        _ = try await service.get(forCategory: category.rawValue, page: 1, limit: 1)
    }
}
