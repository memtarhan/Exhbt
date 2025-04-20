//
//  ExploreViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 09/10/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController {
    var exhbtsViewController: ExhbtsViewController!
    var eventsViewController: EventsViewController!

    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["Exhbts", "Events"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setImage(UIImage.embedText(toImage: UIImage(systemName: "xmark")!, string: "Exhbts", color: .black), forSegmentAt: 0)
        segmentedControl.setImage(UIImage.embedText(toImage: UIImage(systemName: "calendar")!, string: "Events", color: .black), forSegmentAt: 1)

        return segmentedControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Actions

    @objc
    private func didChangeSegment(_ sender: UISegmentedControl) {
        debugLog(self, #function)
        UserSettings.shared.shouldShowEventsAtLaunch.toggle()

        if UserSettings.shared.shouldShowEventsAtLaunch {
            exhbtsViewController.willMove(toParent: nil)
            exhbtsViewController.view.removeFromSuperview()
            exhbtsViewController.removeFromParent()

            displayEvents()

        } else {
            eventsViewController.willMove(toParent: nil)
            eventsViewController.view.removeFromSuperview()
            eventsViewController.removeFromParent()

            displayExhbts()
        }
    }

    @objc
    private func didTapFilter(_ sender: UIBarButtonItem) {
        eventsViewController.displayFilter.send(!eventsViewController.displayFilter.value)
    }

    func setupInitialView() {
        if UserSettings.shared.shouldShowEventsAtLaunch {
            displayEvents()
            segmentedControl.selectedSegmentIndex = 1

        } else {
            displayExhbts()
            segmentedControl.selectedSegmentIndex = 0
        }
    }
}

// MARK: - Setup

private extension ExploreViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        navigationItem.titleView = segmentedControl

        setupInitialView()
    }

    func displayExhbts() {
        guard let exhbtsView = exhbtsViewController.view else { return }
        exhbtsView.translatesAutoresizingMaskIntoConstraints = false

        addChild(exhbtsViewController)
        view.addSubview(exhbtsView)

        NSLayoutConstraint.activate([
            exhbtsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            exhbtsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            exhbtsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            exhbtsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        exhbtsViewController.didMove(toParent: self)

        navigationItem.rightBarButtonItem = nil
    }

    func displayEvents() {
        guard let eventsView = eventsViewController.view else { return }
        eventsView.translatesAutoresizingMaskIntoConstraints = false

        addChild(eventsViewController)
        view.addSubview(eventsView)

        NSLayoutConstraint.activate([
            eventsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            eventsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            eventsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            eventsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        eventsViewController.didMove(toParent: self)

        let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .done, target: self, action: #selector(didTapFilter(_:)))
        navigationItem.rightBarButtonItem = filterButton
    }
}
