//
//  CALayer.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 27/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

extension CALayer {
    func addGradienBorder(colors: [UIColor], width: CGFloat = 1, cornerRadius: CGFloat = 0) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: CGPointZero, size: bounds.size)
        gradientLayer.startPoint = CGPointMake(0.0, 0.5)
        gradientLayer.endPoint = CGPointMake(1.0, 0.5)
        gradientLayer.colors = colors.map({ $0.cgColor })
        gradientLayer.cornerRadius = cornerRadius

        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = width
        shapeLayer.path = UIBezierPath(rect: bounds).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.cornerRadius = cornerRadius
        gradientLayer.mask = shapeLayer

        addSublayer(gradientLayer)
    }
}
