//
//  GalleryProfileCell.swift
//  Exhbt
//
//  Created by Steven Worrall on 6/4/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class GalleryProfileCell: UITableViewCell {

    func set(galleryController: GalleryViewController) {
        contentView.addSubview(galleryController.view)
        galleryController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        galleryController.reloadView()
    }
}
