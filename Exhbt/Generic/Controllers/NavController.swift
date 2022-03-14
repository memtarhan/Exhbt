//
//  NavController.swift
//  Exhbt
//
//  Created by Steven Worrall on 4/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class NavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }

    private func setupView() {
        self.navigationBar.barTintColor = UIColor.init(named: "MainDarkColor")
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 26)]
        self.navigationBar.isTranslucent = false
        self.title = "EXHBT"
    }
}
