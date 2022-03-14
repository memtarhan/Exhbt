//
//  CustomImageView.swift
//  Exhbt
//
//  Created by Shouvik Paul on 6/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

class CustomImageView: UIImageView {
    var imageUrlString: String?
    var imageID: String?
    let sizes: [ImageSize]
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
    init(sizes: [ImageSize]) {
        self.sizes = sizes
        super.init(frame: .zero)
        self.contentMode = .scaleAspectFill
        self.layer.masksToBounds = true
        self.backgroundColor = .lightGray
    }
    
    convenience init(
        imageID: String,
        sizes: [ImageSize]
    ) {
        self.init(sizes: sizes)
        self.setImage(with: imageID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(with imageID: String) {
        self.imageID = imageID
        
        guard !imageID.isEmpty && imageID != "" else { return }
        layoutActivityIndicator()
        var sizeIdentifier = ""
        if !sizes.isEmpty {
            sizeIdentifier = sizes[0].identifier
        }
        self.getImage(imageID, sizeIdentifier: sizeIdentifier)
    }
    
    func layoutActivityIndicator() {
        self.activityIndicatorView.removeFromSuperview()

        addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        if self.image == nil {
            activityIndicatorView.startAnimating()
        }
    }

    func getImage(_ imageID: String, sizeIdentifier: String) {
        guard imageID == self.imageID else {
            self.activityIndicatorView.stopAnimating()
            return
        }
        let imageIDWithSize = imageID + sizeIdentifier
        if let imageFromCache = imageCache.object(forKey: imageID as AnyObject) as? UIImage {
            self.image = imageFromCache
            self.activityIndicatorView.stopAnimating()
            return
        }
        
        ImageRepository().getPhoto(with: imageIDWithSize).then { result in
            guard imageID == self.imageID else {
                self.activityIndicatorView.stopAnimating()
                return
            }
            switch result {
            case .success(let url):
                self.loadImageUsingUrlString(
                    url.absoluteString,
                    imageIDWithSize: imageIDWithSize
                )
            case .failure(_):
                if let nextSizeIdentifier = self.getNextSizeIdentifier(from: sizeIdentifier) {
                    self.getImage(imageID, sizeIdentifier: nextSizeIdentifier)
                } else {
                    // TODO add error state
                    self.activityIndicatorView.stopAnimating()
                }
            }
        }
    }
    
    private func getNextSizeIdentifier(
        from lastAttemptedSizeIdentifier: String
    ) -> String? {
        if lastAttemptedSizeIdentifier == "" {
            return nil
        }
        for (idx, size) in sizes.enumerated() {
            if size.identifier == lastAttemptedSizeIdentifier {
                // if end of array attempt to get full size photo
                if idx + 1 >= sizes.count {
                    return ""
                } else {
                    return sizes[idx + 1].identifier
                }
            }
        }
    
        return nil
    }
    
    func loadImageUsingUrlString(
        _ urlString: String,
        imageIDWithSize: String
    ) {
        let url = URL(string: urlString)
        imageUrlString = urlString
        image = nil

        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let imageID = self.imageID,
                  imageIDWithSize.starts(with: imageID) else {
                    self.activityIndicatorView.stopAnimating()
                    return
            }
            if error != nil {
                print(error!)
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                }
                // TODO: add error state
                return
            }
            guard let data = data,
                  let downloadedImage = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                }
                // TODO: add error state
                return
            }
            DispatchQueue.main.async {
                if self.imageUrlString == urlString {
                    self.image = downloadedImage
                    self.activityIndicatorView.stopAnimating()
                }
                imageCache.setObject(downloadedImage, forKey: self.imageID as AnyObject)
            }
        }.resume()
    }
    
}
