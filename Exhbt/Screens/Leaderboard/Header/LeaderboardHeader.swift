//
//  LeaderboardHeader.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class LeaderboardHeader: UICollectionReusableView {
    static let resuseIdentifier = "LeaderboardHeader"

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .systemBackground
    }
    
}
