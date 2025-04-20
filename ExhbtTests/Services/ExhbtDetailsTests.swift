//
//  ExhbtDetailsTests.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 05/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import XCTest
@testable import Exhbt

final class ExhbtDetailsTests: XCTestCase {

    private var service: ExhbtDetailsServiceProtocol!
    
    override func setUpWithError() throws {
        service = StubExhbtDetailsService()
    }
    
    func testDetailsDecoding() async throws {
        _ = try await service.getExhbt(withId: 74)
    }

}
