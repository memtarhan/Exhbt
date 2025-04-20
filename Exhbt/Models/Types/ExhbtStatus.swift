//
//  ExhbtStatus.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/08/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

enum ExhbtStatus: Int, CaseIterable {
    case submissions = 1
    case live
    case finished
    case archived
}

// MARK: - init

extension ExhbtStatus {
    init(fromType type: ExhbtStatusTypeResponse) {
        switch type {
        case .submissions: self = .submissions
        case .live: self = .live
        case .finished: self = .finished
        case .archived: self = .archived
        }
    }

    init?(fromString string: String) {
        switch string {
        case "submissions": self = .submissions
        case "live": self = .live
        case "finished": self = .finished
        case "archived": self = .archived
        default: return nil
        }
    }
}

// MARK: - Attributes

extension ExhbtStatus {
    var title: String {
        switch self {
        case .submissions:
            return "Submissions"
        case .live:
            return "Live"
        case .finished:
            return "Finished"
        case .archived:
            return "Archived"
        }
    }

    var statusBackgroundColor: UIColor? {
        switch self {
        case .submissions:
            return .titleBackgroundWithOpacity
        case .live, .finished, .archived:
            return .white
        }
    }

    var statusLabelColor: UIColor? {
        switch self {
        case .submissions:
            return .exhbtStatusWaiting
        case .live, .finished:
            return .exhbtStatusLive
        case .archived:
            return .black
        }
    }

    var shouldHideStatusLabel: Bool { self == .finished }

    var timeLeftColor: UIColor? {
        switch self {
        case .submissions:
            return .white
        case .live, .finished, .archived:
            return .black
        }
    }

    var shoulHideAnimation: Bool { self != .live }

    var animationColor: UIColor? { statusLabelColor }

    var middleImageTintColor: UIColor? {
        switch self {
        case .submissions:
            return .white
        case .live, .archived:
            return .black
        case .finished:
            return .systemGreen
        }
    }

    var middleImage: UIImage? {
        switch self {
        case .submissions, .live:
            return UIImage(named: "Dot")
        case .finished:
            return UIImage(systemName: "checkmark")
        case .archived:
            return nil
        }
    }
}

// MARK: - Methods

extension ExhbtStatus {
    func getStatusString(withTimeLeft timeLeft: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 17, weight: .semibold)

        switch self {
        case .submissions:
            let text = "Competitors Joining • \(timeLeft)"
            let attributes = [NSAttributedString.Key.font: font]
            let attributedString = NSAttributedString(string: text, attributes: attributes)

            return attributedString

        case .live:
            let text = "Exhbt is live • \(timeLeft)"
            let attributes = [NSAttributedString.Key.font: font]
            let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
            attributedString.addAttribute(.foregroundColor, value: UIColor.exhbtStatusLive!, range: NSRange(location: 9, length: 4))

            return attributedString

        case .finished:
            let text = "Exhbt is finished"
            let attributes = [NSAttributedString.Key.font: font]
            let attributedString = NSAttributedString(string: text, attributes: attributes)

            return attributedString

        case .archived:
            let text = "Exhbt is archived"
            let attributes = [NSAttributedString.Key.font: font]
            let attributedString = NSAttributedString(string: text, attributes: attributes)

            return attributedString
        }
    }
}
