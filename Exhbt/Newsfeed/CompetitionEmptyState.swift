//
//  CompetitionEmptyState.swift
//  Exhbt
//
//  Created by Steven Worrall on 8/23/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class CompetitionEmptyState: UIView {
    
    private let topLabel = Label(title: "Hmm here's nothing here yet", fontSize: 16, weight: .regular)
    private let bottomLabel = Label(title: "Check back soon!", fontSize: 20, weight: .semiBold)
    
    init() {
        super.init(frame: .zero)
        
        self.setupView()
        self.addSecondaryViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.isHidden = true
        self.isUserInteractionEnabled = false
    }
    
    private func addSecondaryViews() {
        self.addSubview(self.bottomLabel)
        self.bottomLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
        }
        
        self.addSubview(self.topLabel)
        self.topLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.bottomLabel.snp.top).offset(-10)
            make.centerX.equalTo(self.snp.centerX)
        }
    }

}
