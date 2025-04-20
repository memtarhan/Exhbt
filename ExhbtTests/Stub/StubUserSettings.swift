//
//  StubUserSettings.swift
//  ExhbtTests
//
//  Created by Mehmet Tarhan on 17/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
@testable import Exhbt

class StubUserSettings: ProfileSettingsProtocol {
    static let shared = StubUserSettings()

    var signedIn: Bool { true }

    var id: Int {
        get { return 44 }
        set { }
    }

    var voteStyle: VoteStyle? {
        get { return .style2 }
        set {}
    }

    var token: String? {
        get { return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NCIsImV4cCI6MTY4Mzg0MzM1NX0.5vUY8-NVDuF6YUid3NOysdzqnuHL-AjQyswCNW78G-I" }
        set { }
    }

    var shouldUseMockData: Bool {
        get { return false }
        set { }
    }

    func save(response: UserResponse) {
    }
}
