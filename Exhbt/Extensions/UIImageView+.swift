//
//  UIImageView+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 27/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

extension UIImageView {
    func addVideoIndicator() {
        let imageView = UIImageView(image: UIImage(systemName: "play.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tag = -1

        addSubview(imageView)

        imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
    }
}
