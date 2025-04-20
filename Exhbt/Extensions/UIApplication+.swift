//
//  UIApplication+.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 16/03/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

extension UIApplication {
    var edgeInsets: UIEdgeInsets {
        if let scene = UIApplication.shared.connectedScenes.first,
           let windowScene = scene as? UIWindowScene {
            let insets = windowScene.windows.first?.safeAreaInsets ?? .zero
            return insets
        }
        return .zero
    }
}
