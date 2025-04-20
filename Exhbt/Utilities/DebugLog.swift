//
//  DebugLog.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 02/05/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

func debugLog(
    _ tag: Any,
    _ items: Any...) {
    #if DEBUG
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM HH:mm:ss.SSSS"
        let now = dateFormatter.string(from: Date())

        var list: [Any] = []
        let logInfo = now + " " + String(describing: tag)
        list.append(logInfo)
        list.append(contentsOf: items)
        print(list, separator: " ", terminator: "\n")
    #endif
}
