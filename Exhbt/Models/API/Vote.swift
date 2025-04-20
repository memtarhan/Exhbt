//
//  Vote.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 11/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation



// MARK: - AddVoteResponse

struct AddVoteResponse: Decodable {
    let id: Int
}

// MARK: - RemoveVoteResponse

struct RemoveVoteResponse: Decodable {
    let id: Int
}
