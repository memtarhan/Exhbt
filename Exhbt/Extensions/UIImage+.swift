//
//  UIImage+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 13/01/2024.
//  Copyright © 2024 Exhbt LLC. All rights reserved.
//

import UIKit

extension UIImage {
    enum TextPosition {
        case left
        case right
    }

    /// Embeds a text into an image
    /// - Parameters:
    ///   - image: The image to be updated
    ///   - string: The text to be embedded
    ///   - color: Text and image tint color
    ///   - textPosition: The position of embedded text
    ///   - font: The font of embedded text
    /// - Returns: Return an image with text embedded
    class func embedText(toImage image: UIImage,
                         string: String,
                         color: UIColor,
                         textPosition: UIImage.TextPosition = .right,
                         font: UIFont? = nil) -> UIImage {
        let font = font ?? UIFont.systemFont(ofSize: 15.0)
        let expectedTextSize: CGSize = (string as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
        let width: CGFloat = expectedTextSize.width + image.size.width + 5.0
        let height: CGFloat = max(expectedTextSize.height, image.size.width)
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        let fontTopPosition: CGFloat = (height - expectedTextSize.height) / 2.0
        let textOrigin: CGFloat = (textPosition == .right) ? image.size.width + 5 : 0
        let textPoint: CGPoint = CGPoint(x: textOrigin, y: fontTopPosition)
        string.draw(at: textPoint, withAttributes: [NSAttributedString.Key.font: font])
        let flipVertical: CGAffineTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
        context.concatenate(flipVertical)
        let alignment: CGFloat = (textPosition == .right) ? 0.0 : expectedTextSize.width + 5.0
        context.draw(image.cgImage!, in: CGRect(x: alignment, y: (height - image.size.height) / 2.0, width: image.size.width, height: image.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
