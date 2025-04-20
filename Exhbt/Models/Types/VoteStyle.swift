//
//  VoteStyle.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 24/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

enum VoteStyle: Int, CaseIterable, Encodable, Equatable {
    
    case style1 = 1, style2, style3, style4

    var id: Int {
        rawValue
    }

    var settingImage: UIImage? {
        switch self {
        case .style1:
            return UIImage(named: "Vote Style Setting 1")
        case .style2:
            return UIImage(named: "Vote Style Setting 2")
        case .style3:
            return UIImage(named: "Vote Style Setting 3")
        case .style4:
            return UIImage(named: "Vote Style Setting 4")
        }
    }

    var thumbsImage: UIImage? {
        switch self {
        case .style1:
            return UIImage(named: "Vote Style 1")
        case .style2:
            return UIImage(named: "Vote Style 2")
        case .style3:
            return UIImage(named: "Vote Style 3")
        case .style4:
            return UIImage(named: "Vote Style 4")
        }
    }
}
