//
//  ServerService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol ServerServiceProtocol: APIService {
    func check() async throws -> Bool
}

class ServerService: ServerServiceProtocol {
    static let shared = ServerService()
    
    func check() async throws -> Bool {
        debugLog(self, "willCheck")

        let endpoint = "\(baseURL)/server/status"
        guard let url = URL(string: endpoint) else {
            throw HTTPError.invalidEndpoint
        }

        let (_, response) = try await urlSession.data(from: url)
        let httpResponse = response as! HTTPURLResponse
        let statusCode = httpResponse.statusCode
        debugLog(self, "checkServer didCheck tatusCode: \(statusCode)")
        if statusCode >= 200 && statusCode < 300 {
            return true
        }
        return false
    }
}
