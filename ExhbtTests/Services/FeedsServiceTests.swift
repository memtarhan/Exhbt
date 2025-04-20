//
//  FeedsServiceTests.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 17/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import XCTest
@testable import Exhbt

final class FeedsServiceTests: XCTestCase {

    private var service: FeedsServiceProtocol!
    
    override func setUpWithError() throws {
        service = StubFeedService()
    }
    
    func testFetchFeedsDecoding() async throws {        
        _ = try await service.get(atPage: 1)
    }

}
