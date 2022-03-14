//
//  GalleryViewController.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import Firebase

class GalleryViewController: UIViewController {
    let storageRef = storage.reference()
    let userManager = UserManager.shared
    var galleryStrings: [String]
    weak var delegate: ImagePickedDelegate?
    
    private let userCollectionName = "users"
    
    private let cellID = "galleryCellID"
    public var cellPadding: CGFloat = 10
    public var collectionViewPadding: CGFloat = 20
    lazy var cellSize = (self.view.bounds.width / 3) - (self.cellPadding * 2)
    
    lazy var collectonView: UICollectionView = {
        let tempLayout = UICollectionViewFlowLayout()
        tempLayout.scrollDirection = .vertical
        tempLayout.minimumLineSpacing = self.cellPadding
        tempLayout.minimumInteritemSpacing = 0.0
        let tempCollection = UICollectionView(frame: .zero, collectionViewLayout: tempLayout)
        tempCollection.backgroundColor = .clear
        tempCollection.translatesAutoresizingMaskIntoConstraints = false
        return tempCollection
    }()
    
    init() {
        galleryStrings = userManager.user?.images.reversed() ?? []
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(user: User?) {
        galleryStrings = user?.images.reversed() ?? []
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
    }
    
    func reloadView() {
        self.collectonView.reloadData()
    }
    
    private func setupViews() {
        collectonView.backgroundColor = .white
        self.collectonView.delegate = self
        self.collectonView.dataSource = self
        
        self.collectonView.register(GalleryImageCell.self, forCellWithReuseIdentifier: self.cellID)
        
        self.view.addSubview(self.collectonView)
        self.collectonView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(self.collectionViewPadding)
        }
    }
}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.galleryStrings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! GalleryImageCell

        cell.set(galleryStrings[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cellSize, height: self.cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GalleryImageCell else { return }
        
        guard let image = cell.imageView?.image else { return }
        guard let uuid = cell.imageView?.imageID else { return }
        
        self.delegate?.photoWasPicked(image: image, fromGallery: true, imageUUID: uuid)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellPadding
    }
}
