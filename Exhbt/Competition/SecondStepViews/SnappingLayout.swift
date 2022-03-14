//
//  SnappingLayout.swift
//  Exhbt
//
//  Created by Steven Worrall on 9/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class SnappingLayout: UICollectionViewFlowLayout {
    
    private lazy var cellHeight = UIScreen.main.bounds.width * 0.45
    private lazy var cellWidth = self.cellHeight * 0.9

    override func prepare() {
        super.prepare()
        
        scrollDirection = .horizontal
        
        minimumLineSpacing = cellWidth / 4
        minimumInteritemSpacing = cellWidth / 4
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView!.contentInset.left
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView!.bounds.size.width, height: collectionView!.bounds.size.height)
        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        })
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}
