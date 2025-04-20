//
//  Date+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 09/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

extension Date {
    /**
     Returns a boolean indicating if the date is already passed
     */
    var expired: Bool {
        let now = Date()
        let duration = timeIntervalSince1970 - now.timeIntervalSince1970
        return duration < 0
    }

    /**
     Returns a formatted string for time left from given date to now, i.e: 2d left
     */
    var timeLeft: String {
        let now = Date()
        let duration = timeIntervalSince1970 - now.timeIntervalSince1970

        if duration < 0 { return "" }

        let exactTime = duration / (3600 * 24)
        let days = Int(exactTime)

        if days == 0 {
            return "\(duration.asString(style: .positional)) left"

        } else {
            let amount = exactTime
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 1
            let formattedAmount = formatter.string(from: amount as NSNumber)!

            return "\(formattedAmount)d left"
        }
    }

    var notificationTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    var isMoreThanOneDay: Bool {
        let now = Date()
        let elapsedTime = timeIntervalSince1970 - now.timeIntervalSince1970
        return elapsedTime > 60 * 60 * 24
    }
}
