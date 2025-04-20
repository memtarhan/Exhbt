//
//  UIView+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

extension UIView {
    func blink() {
        alpha = 0.2
        UIView.animate(withDuration: 1, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse], animations: {
            self.alpha = 1.0

        }, completion: nil)
    }

    func fillSuperview(padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewTopAnchor = superview?.topAnchor {
            topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
        }
        if let superviewBottomAnchor = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
        }
        if let superviewLeadingAnchor = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
        }
        if let superviewTrailingAnchor = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
        }
    }
}

// MARK: - Nib load

extension UIView {
    func loadFromNib(_ nibName: String) -> UIView {
        return Bundle(for: type(of: self)).loadNibNamed(nibName, owner: self, options: nil)![0] as! UIView
    }
}

extension UIView {
    func makeCircle() {
        layer.cornerRadius = frame.height / 2
    }
}
