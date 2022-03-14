//
//  FullScreenPageViewController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 5/6/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class FullScreenPageViewController: UIPageViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    var pageControl: UIPageControl?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var scrollView: UIScrollView?
        
        for view in view.subviews {
            if view.isKind(of: UIScrollView.self) {
                scrollView = view as? UIScrollView
            } else if view.isKind(of: UIPageControl.self) {
                pageControl = view as? UIPageControl
            }
        }
        
        if let scrollView = scrollView,
            let pageControl = pageControl {
            scrollView.frame = view.bounds
            view.bringSubviewToFront(pageControl)
            pageControl.customPageControl(borderColor: .white, borderWidth: 1)
        }
    }
}
