//
//  UIImageView+Kingfisher.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 19/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Kingfisher
import UIKit

extension UIImageView {
    func loadImage(withURL url: URL? = nil, urlString: String? = nil, isReloading: Bool = false) {
        var trueURL = url
        if let urlString {
            trueURL = URL(string: urlString)
        }

        let options: [KingfisherOptionsInfoItem]? = isReloading ? [.loadDiskFileSynchronously] : nil

        kf.indicatorType = .activity
        kf.setImage(
            with: trueURL,
            placeholder: UIImage(named: "placeholderImage"),
            options: options) {
                result in
                switch result {
                case let .success(value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case let .failure(error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }

//        if let url {
//            let resource = KF.ImageResource(downloadURL: url, cacheKey: "\(url.absoluteString)")
//            KF.resource(resource).set(to: self)
//
//        } else if let urlString {
//            guard let url = URL(string: urlString) else {
//                backgroundColor = .systemBlue
//                return
//            }
//            let resource = KF.ImageResource(downloadURL: url, cacheKey: "\(url.absoluteString)")
//            KF.resource(resource).set(to: self)
//
//        } else {
//            backgroundColor = .systemBlue
//        }
    }
}
