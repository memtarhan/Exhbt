//
//  ViewUtilities.swift
//  Exhbt
//
//  Created by Shouvik Paul on 6/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentAlert(
        title: String,
        message: String,
        completion: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: "Okay",
                style: .default,
                handler: completion)
        )
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentLoadingScreen() {
        guard presentingViewController as? LoadingScreenController == nil else { return }
        present(LoadingScreenController(), animated: false)
    }
    
    func removeLoadingScreen() {
        guard presentedViewController as? LoadingScreenController != nil else { return }
        dismiss(animated: false, completion: nil)
    }
    
    func setNavigationTitleView(image: UIImage? = UIImage(named: "ExhbtLogo")) {
        let imageView = UIImageView(image: image)
        navigationItem.titleView = imageView
    }
    
    func isVisible() -> Bool {
        return self.viewIfLoaded?.window != nil
    }
    
    func presentInviteActivity(competitionID: String, completion: (() -> Void)? = nil) {
        guard let inviteUrl = DeepLinkBuilder.createInviteLink(for: competitionID) else {
            presentAlert(
                title: "Error",
                message: "Could not create invite link. Please try again."
            )
            return
        }

        let inviteText = "Hey! I have challenged you to a photo competition on Exhbt!"
        let sharedObjects = [inviteUrl as AnyObject, inviteText as AnyObject]
        presentActivities(items: sharedObjects, completion: completion)
    }
    
    func presentActivities(items: [AnyObject], completion: (() -> Void)? = nil) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [.postToFacebook, .postToTwitter]
        
        activityViewController.completionWithItemsHandler = { (type, completed, activities, error) in
            if completed {
                completion?()
            }
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
}

extension UIView {
    func heightCoveredByKeyboardOfSize(keyboardSize: CGSize) -> CGFloat {
        let frameInWindow = convert(bounds, to: nil)
        guard let windowBounds = window?.bounds else { return 0 }
        
        let keyboardTop = windowBounds.size.height - keyboardSize.height
        let viewBottom = frameInWindow.origin.y + frameInWindow.size.height
        return max(0, viewBottom - keyboardTop)
    }
}

extension UILabel {
    func setLineHeight(_ lineHeight: CGFloat, centered: Bool = true) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        if centered {
            paragraphStyle.alignment = .center
        }

        let attrString: NSMutableAttributedString
        if let labelAttributedText = self.attributedText {
            attrString = NSMutableAttributedString(attributedString: labelAttributedText)
        } else {
            attrString = NSMutableAttributedString(string: self.text ?? "")
        }
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
}

extension UIButton {
    func addAction(_ action: Selector, for target: Any?) {
        addTarget(target, action: action, for: .touchUpInside)
    }
}

extension UITextField {
    func setLeftPadding(by amount: CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPadding(by amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIPageControl {
    func customPageControl(borderColor: UIColor, borderWidth: CGFloat) {
        subviews.forEach {
            $0.layer.cornerRadius = $0.frame.size.height / 2
            $0.layer.borderColor = borderColor.cgColor
            $0.layer.borderWidth = borderWidth
        }
    }
}

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
    
    func resizeImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension UITableView {
    func lastIndexpath() -> IndexPath {
        let section = max(numberOfSections - 1, 0)
        let row = max(numberOfRows(inSection: section) - 1, 0)

        return IndexPath(row: row, section: section)
    }
}
