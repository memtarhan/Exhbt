//
//  KeyboardController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 6/7/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class KeyboardController: UIViewController {
    private var keyboardShown: Bool = false
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self, selector:
            #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard !keyboardShown else { return }
        keyboardShown = true
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        onKeyboardWillShow(keyboardSize: keyboardRect.size)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard keyboardShown else { return }
        keyboardShown = false
        onKeyboardWillHide()
    }
    
    // methods to be overridden
    func onKeyboardWillShow(keyboardSize: CGSize) {}
    func onKeyboardWillHide() {}
}
