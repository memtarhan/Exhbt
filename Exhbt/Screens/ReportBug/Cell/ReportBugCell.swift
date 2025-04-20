//
//  ReportBugCell.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 10/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

protocol ReportBugCellDelegate: AnyObject {
    func didTapTrash(cell: ReportBugCell)
}

class ReportBugCell: UITableViewCell {
    
    @IBOutlet var reportImageView: UIImageView!
    @IBOutlet var imageNameLabel: UILabel!
    @IBOutlet var imageSizeLabel: UILabel!
    
    static let identifier = "ReportBugCell"
    weak var delegate: ReportBugCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(_ model: ReportScreenshotDisplayModel, on delegate: ReportBugCellDelegate) {
        self.reportImageView.image = model.image
        self.imageNameLabel.text = model.name
        self.imageSizeLabel.text = model.size
        self.delegate = delegate
    }
    
    @IBAction func didTapTrash() {
        delegate?.didTapTrash(cell: self)
    }
}

class ReportBugTableViewDiffableDataSource: UITableViewDiffableDataSource<ReportSection, ReportScreenshotDisplayModel> {}
