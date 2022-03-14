//
//  OnboardingViewController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 5/6/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class OnboardingController: UIViewController {
    
    private lazy var pageController: FullScreenPageViewController = {
        let controller = FullScreenPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil)
        controller.delegate = self
        controller.dataSource = self
        return controller
    }()
    
    private lazy var skipButton: UIButton = {
        let button = Button(title: "Skip", fontSize: 18)
        button.addAction(#selector(skipTap), for: self)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private lazy var nextButton: PrimaryButton = {
        let button = PrimaryButton(title: "Continue", fontSize: 16)
        button.addAction(#selector(nextTap), for: self)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let pageControl = UIPageControl()
    
    private var introControllers: [UIViewController] = []
    private var currentIndex = 0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIPageControl.appearance().pageIndicatorTintColor = .LightestGray()
        UIPageControl.appearance().currentPageIndicatorTintColor = .LightGray()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        setupPageController()
        setupButtons()
        setupPageControl()
    }
    
    private func setupPageController() {
        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let slide0 = OnboardingSlideController(
            imageName: "OnboardingImage1",
            imageSize: CGSize(width: 16, height: 436),
            title: "Challenge your friends and strangers to photo competitions and climb the leaderboards!!")
        
        let slide1 = OnboardingSlideController(
            imageName: "OnboardingImage2",
            imageSize: CGSize(width: 38, height: 296),
            title: "Choose a category, upload a picture, and challenge anyone to a competition.")
        
        let slide2 = OnboardingSlideController(
            imageName: "OnboardingImage3",
            imageSize: CGSize(width: 86, height: 364),
            title: "Competitions are anonymous to ensure the best picture wins.")
        
        let slide3 = OnboardingSlideController(
            imageName: "OnboardingImage4",
            imageSize: CGSize(width: 29, height: 418),
            title: "The winner of the competition receives the coins")
        
        let slide4 = OnboardingSlideController(
            imageName: "OnboardingImage5",
            imageSize: CGSize(width: 64, height: 408),
            title: "The users with the most coins will be featured on the leaderboards as the best artists on the app")
        
        introControllers = [slide0, slide1, slide2, slide3, slide4]
        pageController.setViewControllers([slide0], direction: .forward, animated: false)
    }
    
    private func setupButtons() {
        let inset = CGFloat(24)
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(inset)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(inset)
            make.height.equalTo(48)
        }

        skipButton.setTitleColor(.black, for: .normal)
        view.addSubview(skipButton)
        skipButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(inset)
            make.bottom.equalTo(nextButton.snp.top).offset(-30)
        }
    }
    
    private func setupPageControl() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = 5
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(-12)
            make.height.equalTo(30)
            make.centerY.equalTo(skipButton)
        }
    }
    
    @objc func skipTap() {
        exitOnboarding()
    }
    
    @objc func nextTap() {
        guard let controller = getController(after: introControllers[currentIndex]) else {
            exitOnboarding()
            return
        }
        
        pageController.setViewControllers([controller], direction: .forward, animated: true)
        currentIndex += 1
        pageControl.currentPage = currentIndex
    }
    
    private func exitOnboarding() {
        dismiss(animated: true, completion: nil)
    }
}

extension OnboardingController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = introControllers.firstIndex(of: viewController) {
            if index > 0 {
                return introControllers[index - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getController(after: viewController)
    }
    
    private func getController(after controller: UIViewController) -> UIViewController? {
        if let index = introControllers.firstIndex(of: controller) {
            if index < introControllers.count - 1 {
                return introControllers[index + 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentController = pageViewController.viewControllers?.last,
                let index = introControllers.firstIndex(of: currentController) {
                currentIndex = index
                pageControl.currentPage = index
            }
        }
    }
}
