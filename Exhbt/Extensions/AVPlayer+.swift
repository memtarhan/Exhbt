//
//  AVPlayer+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 27/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
