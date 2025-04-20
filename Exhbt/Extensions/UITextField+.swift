//
//  UITextField+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 25/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit
import Combine

extension UITextField {
    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .map { ($0.object as? UITextField)?.text }
        .eraseToAnyPublisher()
    }
}
