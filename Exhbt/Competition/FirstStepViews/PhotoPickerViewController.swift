//
//  PhotoPickerViewController.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import Photos

class PhotoPickerViewController: UIViewController {
    var assets: PHFetchResult<PHAsset>?
    weak var delegate: ImagePickedDelegate?
    
    private let cellID = "pickerCellID"
    private let cellPadding: CGFloat = 10
    private lazy var cellSize = (self.view.bounds.width / 3) - (self.cellPadding * 2)
    private var currentlySelectedImage: PickerImageCell?
    
    private lazy var collectionView: UICollectionView = {
        let tempLayout = UICollectionViewFlowLayout()
        tempLayout.scrollDirection = .vertical
        tempLayout.minimumLineSpacing = self.cellPadding
        tempLayout.minimumInteritemSpacing = 0.0
        let tempCollection = UICollectionView(frame: .zero, collectionViewLayout: tempLayout)
        tempCollection.backgroundColor = .clear
        tempCollection.translatesAutoresizingMaskIntoConstraints = false
        return tempCollection
    }()
    private let bulkFetchOptions: PHFetchOptions = {
        let temp = PHFetchOptions()
        temp.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        return temp
    }()
    private let photoRequestOptions: PHImageRequestOptions = {
        let temp = PHImageRequestOptions()
        temp.deliveryMode = .highQualityFormat
        temp.resizeMode = .exact
        return temp
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.checkForLibraryPermission()
        
    }
    
    func setupViews() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(PickerImageCell.self, forCellWithReuseIdentifier: self.cellID)
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.top.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    private func checkForLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .authorized {
            self.reloadViews()
            return
        }
        
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            if status == .authorized {
                self?.reloadViews()
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Photo Library", message: "Photo access is necessary to use photos.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }))
                
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func reloadViews() {
        DispatchQueue.main.async {
            // TODO creates an error: "Error returned from daemon: Error Domain=com.apple.accounts Code=7 "(null)""
            self.assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: self.bulkFetchOptions)
            self.collectionView.reloadData()
        }
    }
}

extension PhotoPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.assets != nil) ? self.assets!.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! PickerImageCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let assetToRequest = self.assets?[indexPath.row] else { return }
        let cellCGSize = CGSize(width: self.cellSize, height: self.cellSize)
        
        PHImageManager.default().requestImage(for: assetToRequest, targetSize: cellCGSize, contentMode: .aspectFill, options: self.photoRequestOptions) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            (cell as! PickerImageCell).image = image
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cellSize, height: self.cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let assetToRequest = self.assets?[indexPath.row] else { return }
        
        PHImageManager.default().requestImage(for: assetToRequest, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: self.photoRequestOptions) { [weak self] (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            if let unwrappedImage = image {
                self?.delegate?.photoWasPicked(image: unwrappedImage, fromGallery: false, imageUUID: UUID().uuidString)
            }
        }
    }
}

