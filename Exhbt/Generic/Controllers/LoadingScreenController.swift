//
//  LoadingScreenController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 5/14/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class LoadingScreenController: UIViewController {
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        loadingIndicator.color = .white
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        loadingIndicator.startAnimating()
    }
}
