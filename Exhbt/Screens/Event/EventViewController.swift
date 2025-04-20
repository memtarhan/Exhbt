//
//  EventViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 02/01/2024.
//  Copyright © 2024 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class EventViewController: BaseViewController, Nibbable {
    var viewModel: EventViewModel!

    var eventId: Int?

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()

        viewModel.eventId = eventId
        viewModel.load()
    }
}

// MARK: - Setup

private extension EventViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Event"
        navigationController?.navigationBar.tintColor = .systemBlue

        startLoading()
    }

    func setupSubscribers() {
        viewModel.eventPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                self?.display(event: event)
                self?.stopLoading()
            }
            .store(in: &cancellables)

        viewModel.shouldPresentDetails
            .receive(on: RunLoop.main)
            .sink { event in
                self.presentPosts(forEvent: event.id)
            }
            .store(in: &cancellables)

        viewModel.eligibleToJoinPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] eligible in
                self?.stopLoading()
                if !eligible {
                    self?.displayIneligibilityAlert(message: "You do not have enough coins to join this Event but you can earn coins with Flash game", completion: {
                        self?.dismiss(animated: true)
                        UserSettings.shared.shouldShowFlashAtLaunch = true
                        AppState.shared.shouldShowFlash.send()
                    })
                }
            }
            .store(in: &cancellables)

        viewModel.joinedPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] joined in
                self?.stopLoading()
                if !joined {
                    self?.displayAlert(withTitle: "Oops, failed to join", message: "Please, try again later.", completion: nil)
                }
            })
            .store(in: &cancellables)
    }

    func display(event: EventDisplayModel) {
        let preview = EventPreview(event: event, onJoin: {
            self.viewModel.join()
        })

        let config = UIHostingConfiguration {
            preview
        }
        let eventPreview = config.makeContentView()

        eventPreview.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(eventPreview)

        NSLayoutConstraint.activate([
            eventPreview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            eventPreview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            eventPreview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            eventPreview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

// MARK: - Router

extension EventViewController: Router { }
