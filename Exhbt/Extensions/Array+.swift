//
//  Array+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 22/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
