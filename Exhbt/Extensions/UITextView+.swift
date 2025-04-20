//
//  UITextView+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 25/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit
import Combine

extension UITextView {
    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default.publisher(
            for: UITextView.textDidChangeNotification,
            object: self
        )
        .map { ($0.object as? UITextView)?.text }
        .eraseToAnyPublisher()
    }
}
