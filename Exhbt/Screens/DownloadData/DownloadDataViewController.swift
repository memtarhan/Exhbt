//
//  DownloadDataViewController.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 09/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class DownloadDataViewController: UIViewController, Nibbable {
    
    var viewModel: DownloadDataViewModel!
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var requestDownloadButton: UIButton!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Download Data"
        viewModel.checkRequestDownloadEnable.send(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisAppear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    @objc
    func keyboardWillAppear(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight: CGFloat
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0.0
        keyboardHeight = keyboardFrame.cgRectValue.height - tabBarHeight
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    func keyboardWillDisAppear(notification: NSNotification?) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 16
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func emailFieldEditingChanged(_ sender: Any) {
        viewModel.checkRequestDownloadEnable.send(true)
    }
    
    @IBAction func didTapRequestDownload() {
        
    }
}
