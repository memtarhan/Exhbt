//
//  ModalViewController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 9/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    
    var modalView: UIView = UIView()
    let showCloseButton: Bool
    
    init(showCloseButton: Bool = true) {
        self.showCloseButton = showCloseButton
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupModalView()
    }
    
    private func setupModalView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        modalView.layer.cornerRadius = 8
        modalView.backgroundColor = .white
        view.addSubview(modalView)
        modalView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        setupCloseButton()
    }
    
    private func setupCloseButton() {
        guard showCloseButton else { return }
        
        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "NewsfeedSkipImage"), for: .normal)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        closeButton.addAction(#selector(closeTap), for: self)
        modalView.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview().inset(12)
            make.width.height.equalTo(44)
        }
    }
    
    @objc func closeTap() {
        dismiss(animated: true, completion: nil)
    }
}
