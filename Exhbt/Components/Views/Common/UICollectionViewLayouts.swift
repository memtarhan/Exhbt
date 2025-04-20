//
//  UICollectionViewLayouts.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 16/06/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

class UICollectionViewLayouts {
    private var imagesFlowLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
//        layout.itemSize = CGSize(width: view.frame.width, height: contentCollectionView.frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        return layout
    }

    private var thumbnailsFlowLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 37, height: 51.8)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

        return layout
    }
}
