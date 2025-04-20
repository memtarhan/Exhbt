//
//  UIViewController+UIAlertController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 14/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

struct AlertAction {
    let title: String
    let image: UIImage?
    let style: UIAlertAction.Style
    let handler: ((UIAlertAction) -> Void)?

    init(title: String, image: UIImage?, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) {
        self.title = title
        self.image = image
        self.style = style
        self.handler = handler
    }
}

extension UIViewController {
    
    func presentActionSheet(withTitle title: String?,
                            message: String?,
                            actions: [AlertAction]) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { action in
            actionSheet.addAction(UIAlertAction(title: action.title, style: action.style, image: action.image, handler: action.handler))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = [] // No arrow for the popover
        }
        present(actionSheet, animated: true)
    }
}

extension UIAlertAction {
    convenience init(title: String, style: UIAlertAction.Style = .default, image: UIImage?, handler: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: title, style: style, handler: handler)
        if let image = image {
            setValue(image, forKey: "image")
        }
    }
}
