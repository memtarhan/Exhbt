//
//  TimeInterval+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 23/04/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

extension TimeInterval {
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = style
        return formatter.string(from: self) ?? ""
    }
}
