//
//  CropImageViewController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 8/23/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

protocol CropImageViewControllerDelegate: AnyObject {
    func didCropImage(_ image: UIImage)
}

class CropImageViewController: UIViewController {
    
    let scrollImage = UIScrollView()
    let imageView: UIImageView
    
    let croppedView = UIView()
    let cropButton: Button = {
        let temp = Button(title: "Crop", fontSize: 18)
        temp.setTitleColor(UIColor.white, for: .normal)
        temp.backgroundColor = .clear
        return temp
    }()
    let cancelButton: Button = {
        let temp = Button(title: "Cancel", fontSize: 18)
        temp.setTitleColor(UIColor.white, for: .normal)
        temp.backgroundColor = .clear
        temp.isUserInteractionEnabled = true
        return temp
    }()
    
    weak var delegate: CropImageViewControllerDelegate?
    
    init(image: UIImage) {
        self.imageView = UIImageView(image: image)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setImageFrame() {
        guard let image = imageView.image else { return }
        
        let ratio = view.frame.width / image.size.width
        let imageHeight = image.size.height * ratio
        
        
        scrollImage.contentSize = CGSize(
            width: view.frame.width,
            height: imageHeight)
        
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: imageHeight)
        
        let centerOffsetY = (imageHeight - scrollImage.frame.size.height) / 2
        scrollImage.contentOffset = CGPoint(x: 0, y: centerOffsetY)
    }
    
    private func setupView() {
        view.backgroundColor = .black
        setupScrollImage()
        setupCroppedView()
        setupButtons()
        
        view.layoutIfNeeded()
        setImageFrame()
    }
    
    private func setupScrollImage() {
        scrollImage.delegate = self
        scrollImage.backgroundColor = .black
        scrollImage.alwaysBounceVertical = false
        scrollImage.alwaysBounceHorizontal = false
        scrollImage.showsVerticalScrollIndicator = true
        scrollImage.flashScrollIndicators()
        
        scrollImage.minimumZoomScale = 1.0
        scrollImage.maximumZoomScale = 10.0
        
        scrollImage.frame = view.frame
        view.addSubview(scrollImage)
        imageView.clipsToBounds = false
        imageView.contentMode = .scaleAspectFit
        scrollImage.addSubview(imageView)
        
        scrollImage.snp.makeConstraints { (make) in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(TopProfileCell.imageHeight)
        }
    }
    
    private func setupCroppedView() {
        croppedView.isUserInteractionEnabled = false
        croppedView.layer.borderColor = UIColor.EXRed().cgColor
        croppedView.layer.borderWidth = 3
        view.addSubview(croppedView)
        croppedView.snp.makeConstraints { (make) in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(TopProfileCell.imageHeight)
        }
    }
    
    private func setupButtons() {
        cancelButton.addAction(#selector(cancelTap), for: self)
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.left.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        cropButton.addAction(#selector(cropTap), for: self)
        view.addSubview(cropButton)
        cropButton.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.right.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc func cancelTap() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cropTap() {
        guard let image = imageView.image else {
            presentCropFailure()
            return
        }
        
        let imageViewScale = max(
            image.size.width / imageView.frame.width,
            image.size.height / imageView.frame.height)
        
        let cropRect = CGRect(
            x: scrollImage.contentOffset.x,
            y: scrollImage.contentOffset.y,
            width: scrollImage.frame.width,
            height: scrollImage.frame.height)
        
        let cropZone = CGRect(
            x: cropRect.origin.x * imageViewScale,
            y: cropRect.origin.y * imageViewScale,
            width: cropRect.size.width * imageViewScale,
            height: cropRect.size.height * imageViewScale)
        
        UIGraphicsBeginImageContextWithOptions(cropZone.size, false, image.scale)
        image.draw(at: CGPoint(
            x: -cropZone.origin.x,
            y: -cropZone.origin.y))
        let currentImageContext = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let croppedImage = currentImageContext else {
            presentCropFailure()
            return
        }
        
        delegate?.didCropImage(croppedImage)
        dismiss(animated: true, completion: nil)
    }
    
    private func presentCropFailure() {
        presentAlert(
            title: "Error",
            message: "Sorry there was an error cropping the image. Please try again")
    }
}

extension CropImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
