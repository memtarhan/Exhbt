//
//  GradientLayers.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 04/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

enum GradientLayers {
    static var exhbtStatusWhiteCover: CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            (UIColor(named: "GradientClearWhite") ?? .clear).cgColor,
            (UIColor(named: "GradientOpacityWhite") ?? .white.withAlphaComponent(0.1)).cgColor,
        ]
        return gradient
    }
}
