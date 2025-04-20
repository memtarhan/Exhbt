//
//  SegmentedControlHeader.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

struct SegmentedControlItem {
    let image: UIImage
    let title: String
}

protocol SegmentedControlHeaderDelegate: AnyObject {
    func segmentedControlHeader(didChangeTo index: Int)
}

class SegmentedControlHeader: UICollectionReusableView {
    static let reuseIdentifier = "SegmentedControlHeader"

    @IBOutlet var segmentedControl: UISegmentedControl!

    weak var delegate: SegmentedControlHeaderDelegate?

    var images: [UIImage?]? {
        didSet {
            segmentedControl.removeAllSegments()
            images?.enumerated().forEach { index, image in
                segmentedControl.insertSegment(with: image, at: index, animated: false)
            }
        }
    }

    var titles: [String]? {
        didSet {
            segmentedControl.removeAllSegments()
            titles?.enumerated().forEach { index, title in
                segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
            }
        }
    }

    var items: [SegmentedControlItem]? {
        didSet {
            segmentedControl.removeAllSegments()
            items?.enumerated().forEach { index, item in
                segmentedControl.insertSegment(with: UIImage.embedText(toImage: item.image, string: item.title, color: .black, font: UIFont.systemFont(ofSize: 13)), at: index, animated: false)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        segmentedControl.removeAllSegments()
    }

    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        delegate?.segmentedControlHeader(didChangeTo: sender.selectedSegmentIndex)
    }

    func setSelectedSegment(_ index: Int) {
        segmentedControl.selectedSegmentIndex = index
    }
}
