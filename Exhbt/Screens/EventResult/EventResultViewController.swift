//
//  EventResultViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 20/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class EventResultViewController: BaseViewController, Nibbable {
    var viewModel: EventResultViewModel!

    @IBOutlet var imageView: UIImageView!
    private var winnerSubview: (UIView & UIContentView)?

    var eventId: Int?

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true

        setupSubscribers()
        viewModel.eventId = eventId
        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true)
    }
}

private extension EventResultViewController {
    func displayWinner(_ winner: WinnerModel) {
        let winnerContentView = WinnerView(winner: winner) {
            self.winnerSubview?.removeFromSuperview()
            self.displayResult()
            self.viewModel.loadResults()
        }

        let config = UIHostingConfiguration {
            winnerContentView
        }
        winnerSubview = config.makeContentView()

        guard let winnerSubview else { return }

        winnerSubview.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(winnerSubview)

        NSLayoutConstraint.activate([
            winnerSubview.topAnchor.constraint(equalTo: view.topAnchor),
            winnerSubview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            winnerSubview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            winnerSubview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func displayResult() {
        navigationController?.navigationBar.isHidden = false

        view.backgroundColor = .black

        startLoading()
    }

    func setupSubscribers() {
        viewModel.winnerPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { winner in
                self.displayWinner(winner)
            }
            .store(in: &cancellables)

        viewModel.ranksPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { ranks in
                self.stopLoading()
                // Top Ranks
                let config = UIHostingConfiguration {
                    EventResultTopRanksRow(data: ranks.0) { userId in
                        self.presentUser(withId: userId)
                    }
                }
                let subview = config.makeContentView()
                subview.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(subview)

                NSLayoutConstraint.activate([
                    subview.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
                    subview.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                    subview.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                    subview.heightAnchor.constraint(equalToConstant: 228),
                ])

                if !ranks.1.isEmpty {
                    // Bottom Ranks
                    let config2 = UIHostingConfiguration {
                        EventResultBottomRanksView(data: ranks.1) { userId in
                            self.presentUser(withId: userId)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    let subview2 = config2.makeContentView()
                    subview2.translatesAutoresizingMaskIntoConstraints = false
                    self.view.addSubview(subview2)

                    NSLayoutConstraint.activate([
                        subview2.topAnchor.constraint(equalTo: subview.bottomAnchor, constant: 32),
                        subview2.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: -16),
                        subview2.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
                        subview2.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 96),
                    ])
                }

            })
            .store(in: &cancellables)

        viewModel.titlePublisher
            .receive(on: RunLoop.main)
            .sink { _ in
            } receiveValue: { title in
                self.navigationItem.title = title
            }
            .store(in: &cancellables)
    }
}

// MARK: - Router

extension EventResultViewController: Router { }
