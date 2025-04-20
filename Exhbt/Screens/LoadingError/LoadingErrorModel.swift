//
//  LoadingErrorModel.swift
//  Exhbt
//
//  Created by Adem Tarhan on 31.08.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

// TODO: Improve naming these cases
enum LoadingFailureType {
    case typeA
    case typeB

    static var random: LoadingFailureType {
        let randomIndex = Int.random(in: 0 ... 1)
        return [LoadingFailureType.typeA, typeB][randomIndex]
    }

    static func getType(forError error: ExError = HTTPError.failed) -> LoadingFailureType {
        let randomIndex = Int.random(in: 0 ... 1)
        return [LoadingFailureType.typeA, typeB][randomIndex]
    }
}

enum LoadingResultType {
    case success
    case failure(LoadingFailureType)
}
