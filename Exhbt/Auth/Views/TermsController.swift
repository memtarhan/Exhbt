//
//  TermsController.swift
//  Exhbt
//
//  Created by Steven Worrall on 1/19/21.
//  Copyright © 2021 Exhbt LLC. All rights reserved.
//

import UIKit

protocol TermsControllerDelegate: AnyObject {
    func acceptedEULA()
}

class TermsController: UIViewController {
    weak var delegate: TermsControllerDelegate?
    
    lazy var acceptButton: Button = {
        let temp = Button(title: "Accept", fontSize: 14)
        temp.backgroundColor = .EXRed()
        temp.setTitleColor(.white, for: .normal)
        temp.addTarget(self, action: #selector(acceptTap), for: .touchUpInside)
        return temp
    }()
    
    let buttonView: UIView = {
        let temp = UIView()
        temp.backgroundColor = .white
        return temp
    }()
    
    lazy var label: UITextView = {
        let temp = UITextView()
        temp.backgroundColor = .white
        temp.text = self.EULA
        temp.font = UIFont(name: "HelveticaNeue", size: 15)
        temp.textColor = .DarkGray()
        temp.isEditable = false
        return temp
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setupView() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.buttonView)
        self.buttonView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        
        self.buttonView.addSubview(self.acceptButton)
        self.acceptButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(25)
            make.width.equalTo(120)
        }
        
        self.view.addSubview(self.label)
        self.label.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(self.buttonView.snp.top)
        }
    }
    
    @objc func acceptTap() {
        self.delegate?.acceptedEULA()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    let EULA = "End-User License Agreement (EULA) of Exhbt\n\nThis End-User License Agreement (\"EULA\") is a legal agreement between you and Exhbt LLC. Our EULA was created by EULA Template for Exhbt.\n\nThis EULA agreement governs your acquisition and use of our Exhbt software (\"Software\") directly from Exhbt LLC or indirectly through a Exhbt LLC authorized reseller or distributor (a \"Reseller\"). Our Privacy Policy was created by the Privacy Policy Generator.\n\nPlease read this EULA agreement carefully before completing the installation process and using the Exhbt software. It provides a license to use the Exhbt software and contains warranty information and liability disclaimers.\n\nIf you register for a free trial of the Exhbt software, this EULA agreement will also govern that trial. By clicking \"accept\" or installing and/or using the Exhbt software, you are confirming your acceptance of the Software and agreeing to become bound by the terms of this EULA agreement.\n\nIf you are entering into this EULA agreement on behalf of a company or other legal entity, you represent that you have the authority to bind such entity and its affiliates to these terms and conditions. If you do not have such authority or if you do not agree with the terms and conditions of this EULA agreement, do not install or use the Software, and you must not accept this EULA agreement.\n\nThis EULA agreement shall apply only to the Software supplied by Exhbt LLC herewith regardless of whether other software is referred to or described herein. The terms also apply to any Exhbt LLC updates, supplements, Internet-based services, and support services for the Software, unless other terms accompany those items on delivery. If so, those terms apply.\n\nLicense Grant\n\nExhbt LLC hereby grants you a personal, non-transferable, non-exclusive licence to use the Exhbt software on your devices in accordance with the terms of this EULA agreement.\n\nYou are permitted to load the Exhbt software (for example a PC, laptop, mobile or tablet) under your control. You are responsible for ensuring your device meets the minimum requirements of the Exhbt software.\n\nYou are not permitted to:\n\nEdit, alter, modify, adapt, translate or otherwise change the whole or any part of the Software nor permit the whole or any part of the Software to be combined with or become incorporated in any other software, nor decompile, disassemble or reverse engineer the Software or attempt to do any such things\n\nReproduce, copy, distribute, resell or otherwise use the Software for any commercial purpose\n\nThere is no tolerance for objectionable content or abusive users.  Offending content that is flagged will be removed and risks the user being removed.\n\nAllow any third party to use the Software on behalf of or for the benefit of any third party\n\nUse the Software in any way which breaches any applicable local, national or international law\n\nuse the Software for any purpose that Exhbt LLC considers is a breach of this EULA agreement\n\nIntellectual Property and Ownership\n\nExhbt LLC shall at all times retain ownership of the Software as originally downloaded by you and all subsequent downloads of the Software by you. The Software (and the copyright, and other intellectual property rights of whatever nature in the Software, including any modifications made thereto) are and shall remain the property of Exhbt LLC.\n\nExhbt LLC reserves the right to grant licences to use the Software to third parties.\n\nTermination\n\nThis EULA agreement is effective from the date you first use the Software and shall continue until terminated. You may terminate it at any time upon written notice to Exhbt LLC.\n\nIt will also terminate immediately if you fail to comply with any term of this EULA agreement. Upon such termination, the licenses granted by this EULA agreement will immediately terminate and you agree to stop all access and use of the Software. The provisions that by their nature continue and survive will survive any termination of this EULA agreement.\n\nGoverning Law\n\nThis EULA agreement, and any dispute arising out of or in connection with this EULA agreement, shall be governed by and construed in accordance with the laws of us."

}
