//
//  SplashViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class SplashViewController: UIViewController, Nibbable {
    var viewModel: SplashViewModel!

    // MARK: - IBOutlets

    @IBOutlet var logoImageView: UIImageView!

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscribers()
        logoImageView.blink()
        viewModel.triggerDataFetch()
    }

    private func setupSubscribers() {
        viewModel.fetchedInitialData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    self?.presentTabBar()
                case .failure:
                    self?.presentOnboarding()
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellables)

        viewModel.shouldDisplayMissingDetails
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.presentMissingAccountDetails()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Router

extension SplashViewController: Router {}

fileprivate let dummyUsers: [(id: Int, token: String)] = [
    (id: 50, token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1MCIsImV4cCI6MTY4NzM2NTc4N30.g2E8P8V_3MmSmdtzP7yRbefLif1TMkDoXTxV3fornjo"),
    (id: 51, token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1MSIsImV4cCI6MTY4NzM2NTg1MX0.owBpYh39LJTrHUmFH0asXgZY6VP-p8hYBSYalOPyZRI"),
    (id: 52, token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1MiIsImV4cCI6MTY4NzM2NTg4NH0.zv_8BsUU-z_7GAOsBV_5n05S-ae-hSS0UZbWLyjaNRw"),
]
