//
//  ExhbtType.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 20/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

enum ExhbtType: String, CaseIterable {
    case `public`
    case `private`

    var title: String {
        switch self {
        case .public:
            return "Public, Open to All"
        case .private:
            return "Private, Invites Only"
        }
    }

    var image: UIImage? {
        switch self {
        case .public:
            return UIImage(systemName: "globe")
        case .private:
            return UIImage(systemName: "envelope")
        }
    }

    var emoji: String {
        switch self {
        case .public:
            return "🌐"
        case .private:
            return "📩"
        }
    }

    var info: String {
        switch self {
        case .public:
            return "everyone can join."
        case .private:
            return "people you invite can join."
        }
    }
}
