//
//  SettingsController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 6/6/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {
    private var user: User
    
    let logoutButton: Button = {
        let temp = Button(title: "Logout")
        temp.contentHorizontalAlignment = .left
        temp.setTitleColor(.EXRed(), for: .normal)
        temp.titleLabel?.font = UIFont(name: FontWeight.regular.rawValue, size: 18)
        return temp
    }()
    
    let blockButton: Button = {
        let temp = Button(title: "My Blocked List")
        temp.contentHorizontalAlignment = .left
        temp.titleLabel?.font = UIFont(name: FontWeight.regular.rawValue, size: 18)
        return temp
    }()
    
    let privateProfileView: UIView = {
        let temp = UIView()
        temp.backgroundColor = .clear
        
        let tempLabel = Label(title: "Private Profile", fontSize: 18, weight: .regular)
        temp.addSubview(tempLabel)
        tempLabel.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
        }
        
        return temp
    }()
    
    let profileInteractor = ProfileInteractor()
    
    init(user: User) {
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        
        self.setupPrivateProfileToggle()
        self.setupBlockedUsers()
        self.setupLogout()
    }
    
    private func setupPrivateProfileToggle() {
        self.view.addSubview(self.privateProfileView)
        self.privateProfileView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.leading.trailing.top.equalToSuperview().inset(10)
            
        }
        
        let tempSwitch = UISwitch()
        tempSwitch.isOn = self.user.privateProfile
        tempSwitch.addTarget(self, action: #selector(self.switchValueDidChange(_:)), for: .valueChanged)
        
        self.privateProfileView.addSubview(tempSwitch)
        tempSwitch.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupBlockedUsers() {
        self.blockButton.addAction(#selector(self.blockedTap), for: self)
        self.view.addSubview(blockButton)
        self.blockButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(self.privateProfileView.snp.bottom)
        }
    }
    
    private func setupLogout() {
        self.logoutButton.addAction(#selector(self.logoutTap), for: self)
        self.view.addSubview(logoutButton)
        self.logoutButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(self.blockButton.snp.bottom)
        }
    }
    
    @objc func switchValueDidChange(_ sender: UISwitch!) {
        if (sender.isOn == true){
            print("on")
            user.privateProfile = true
        }
        else{
            print("off")
            user.privateProfile = false
        }
        profileInteractor.updateUser(user)
    }
    
    @objc func blockedTap() {
        print("Blocked tapped")
        let controller = BlockController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func logoutTap() {
        UserManager.shared.logout()
    }
}
