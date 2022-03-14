//
//  CustomIntensityVisualEffectView.swift
//  Exhbt
//
//  Created by Shouvik Paul on 6/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

//usage:
//let tempBlur = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .regular), intensity: 0.05)
//tempBlur.frame = self.view.bounds
//overlay.addSubview(tempBlur)
class CustomIntensityVisualEffectView: UIVisualEffectView {

    /// Create visual effect view with given effect and its intensity
    ///
    /// - Parameters:
    ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
    ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
    init(effect: UIVisualEffect, intensity: CGFloat) {
        super.init(effect: nil)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in self.effect = effect }
        animator.fractionComplete = intensity
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: Private
    private var animator: UIViewPropertyAnimator!
}
