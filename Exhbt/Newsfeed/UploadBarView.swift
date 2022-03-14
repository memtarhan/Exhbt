//
//  UploadBarView.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/4/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import SnapKit

protocol UploadBarDelegate: AnyObject {
    func finishedUploading(ID: String)
}

class UploadBarView: UIView {
    weak var delegate: UploadBarDelegate?
    
    public var competitionID: String
    
    private var barWidthContraint: Constraint?
    private lazy var currentBarOffset: CGFloat = 0.0
    
    private lazy var barView: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.init(named: "GoldButtonColor")
        return temp
    }()

    init(competitionID: String) {
        self.competitionID = competitionID
        super.init(frame: .zero)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        self.addSubview(self.barView)
        self.barView.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            barWidthContraint = make.width.equalTo(self.currentBarOffset).constraint
        }
    }
    
    public func updateWithPercent(percentChange: CGFloat) {
        let barWidth: CGFloat = self.bounds.width
        let singlePercentOfWidth: CGFloat = barWidth / 100
        
        let widthToMove = singlePercentOfWidth * percentChange
        self.currentBarOffset += widthToMove
        
        if self.currentBarOffset >= barWidth {
            delegate?.finishedUploading(ID: self.competitionID)
        }
        
        self.barWidthContraint?.update(offset: self.currentBarOffset)
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
}
