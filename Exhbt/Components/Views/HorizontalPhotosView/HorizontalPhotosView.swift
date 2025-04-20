//
//  FeedPicturesView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 10/04/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Kingfisher
import UIKit

// TODO: Fix this model
struct HorizontalPhotoModel: Hashable {
    let url: String
    let videoURL: String?
    let isVideo: Bool

    init(url: String, videoURL: String?, isVideo: Bool) {
        self.url = url
        self.videoURL = videoURL
        self.isVideo = isVideo
    }
    
    init(withResponse response: ContentResponse) {
        let isVideo = response.mediaType == .video
        let videoURL = response.video?.url
        let url = response.photo?.medium ?? response.video?.thumbnail

        self.url = url!
        self.videoURL = videoURL
        self.isVideo = isVideo
    }

    init(withDisplayModel model: MediaDisplayModel) {
        url = model.url
        videoURL = model.videoUrl
        isVideo = model.mediaType == .video
    }
}

class HorizontalPhotosView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var gradientImageView: UIImageView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet var separatorViews: [UIView]!

    var id: Int?
    var color: UIColor?

    var images: [UIImage]? {
        didSet {
            if let pictures = images {
                update(pictures)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // TODO: - Needs to remove seperator at the end
    func update(models: [HorizontalPhotoModel]) {
        contentView.backgroundColor = .clear // color
        showPicturesStackView()
        hidePicturesStackView(models.count)

        guard !models.isEmpty else { return }
        var imagesStack = models

        // Limiting number of images to 10
        if imagesStack.count > 10 {
            let newStack = imagesStack.prefix(10)
            imagesStack = Array(newStack)
        }

        for index in 0 ..< imagesStack.count {
            let model = imagesStack[index]
            let imageView = imageViews[index]

//            guard let id = id else {
//                return
//            }
//
//            let cacheId = generateCacheId(for: id, index: index)

            imageView.loadImage(urlString: model.url)
            if model.isVideo {
                imageView.addVideoIndicator()
            }

//            if let uiImage = cache.object(forKey: cacheId) {
//                imageView.image = uiImage
//                debugLog(self, "Cached image for \(cacheId)")
//                gradientImageView.isHidden = false
//
//            } else {
//                if shouldLoadLazy {
//                    if let url = URL(string: thumbnail) {
//                        imageView.kf.setImage(with: url) { [weak self] _ in
//                            guard let self = self else { return }
//                            self.loadOriginalImage(image, tempURL: url, imageView: imageView, cacheId: cacheId)
//                            self.gradientImageView.isHidden = false
//                        }
//                    }
//
//                } else {
//                    if let url = URL(string: image) {
//                        imageView.kf.setImage(with: url)
//                    }
//                }
//
//            }
        }
    }

//    private func loadOriginalImage(_ originalURL: String, tempURL: URL, imageView: UIImageView, cacheId: NSString) {
//        if let url = URL(string: originalURL) {
//            imageView.kf.setImage(with: url, placeholder: imageView.image, options: [.keepCurrentImageWhileLoading, .lowDataMode(.network(tempURL))]) { [weak self] result in
//                guard let self = self else { return }
//                switch result {
//                case let .success(value):
//                    let uiImage = value.image as UIImage
//                    self.cache.setObject(uiImage, forKey: cacheId)
//
//                case let .failure(error):
//                    debugLog(self, "Image: large Image: Error: \(error)")
//                }
//            }
//        }
//    }

    func update(_ images: [UIImage]) {
        hidePicturesStackView(images.count)
        zip(images, imageViews).forEach { image, imageView in
            imageView.image = image
        }
    }

    private func hidePicturesStackView(_ count: Int) {
        if count == 0 {
            imageViews.forEach { $0.isHidden = true }
            separatorViews.forEach { $0.isHidden = true }

        } else {
            imageViews.forEach { $0.image = nil }
            if count < imageViews.count {
                for idx in count ..< imageViews.count {
                    imageViews[idx].isHidden = true
                    if idx < separatorViews.count {
                        separatorViews[idx].isHidden = true
                        separatorViews[idx - 1].isHidden = true
                    }
                }
            }
        }
    }

    private func showPicturesStackView() {
        imageViews.forEach {
            $0.image = nil
            $0.isHidden = false
        }
        separatorViews.forEach {
            $0.isHidden = false
        }
    }

//    private func generateCacheId(for id: Int, index: Int) -> NSString {
//        let cacheId = "\(id)-\(index)"
//        return NSString(string: cacheId)
//    }

    func setup() {
        contentView = loadFromNib(String(describing: HorizontalPhotosView.self))
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        layer.cornerRadius = FeedTableViewCell.cornerRadius
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        gradientImageView.layer.cornerRadius = FeedTableViewCell.cornerRadius
        gradientImageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        gradientImageView.isHidden = true

        contentView.layer.cornerRadius = FeedTableViewCell.cornerRadius
        contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        stackView.layer.cornerRadius = FeedTableViewCell.cornerRadius
        stackView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        stackView.spacing = 0

        stackView.distribution = .fill
        stackView.alignment = .fill
    }

    /**
     Makes all corners rounded
     */
    func makeRounded() {
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
