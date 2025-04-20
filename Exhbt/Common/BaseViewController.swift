//
//  BaseViewController.swift
//  Exhbt
//
//  Created by Adem Tarhan on 31.08.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class WrappedView: UIView {
    private(set) var view: UIView!

    init(view: UIView) {
        self.view = view
        super.init(frame: CGRect.zero)
        addSubview(view)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        view.frame = bounds
    }
}

/**
 * Adapts a SwiftUI view for use inside a UIViewController.
 */
class SwiftUIAdapter<Content> where Content: View {
    private(set) var view: Content!
    private(set) weak var parent: BaseViewController!
    private(set) var uiView: WrappedView
    private var hostingController: UIHostingController<Content>

    init(view: Content, parent: BaseViewController, backgroundColor: UIColor = .clear) {
        self.view = view
        self.parent = parent
        hostingController = UIHostingController(rootView: view)
        parent.addChild(hostingController)
        hostingController.didMove(toParent: parent)
        uiView = WrappedView(view: hostingController.view)

        hostingController.view.backgroundColor = backgroundColor
    }

    deinit {
        hostingController.removeFromParent()
        hostingController.didMove(toParent: nil)
    }
}

struct BaseSwiftUIView: View {
    var body: some View {
        Text("Hey")
    }
}

class BaseViewController: UIViewController {
    private var adapter: SwiftUIAdapter<LoadingContentView>?
    private var emptyStateAdapter: SwiftUIAdapter<EmptyStateView>?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func startLoading() {
        adapter = SwiftUIAdapter(view: LoadingContentView(result: .success), parent: self, backgroundColor: .clear)
        let uiView = adapter!.uiView
        uiView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(uiView)

        NSLayoutConstraint.activate([
            uiView.topAnchor.constraint(equalTo: view.topAnchor),
            uiView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            uiView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            uiView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    func stopLoading(withResult result: LoadingResultType = .success) {
        switch result {
        case .success:
            adapter?.uiView.removeFromSuperview()
            adapter = nil
            let views = view.subviews.filter { $0 is WrappedView }
            views.forEach { $0.removeFromSuperview() }
            break
        case let .failure(loadingFailureType):
            let contentView = LoadingContentView(result: .failure(loadingFailureType)) { [weak self] in
                self?.adapter?.uiView.removeFromSuperview()
                self?.adapter = nil

                let views = self?.view.subviews.filter { $0 is WrappedView }
                views?.forEach { $0.removeFromSuperview() }

                self?.tabBarController?.tabBar.isHidden = false
                self?.navigationController?.setNavigationBarHidden(false, animated: false)
            }
            tabBarController?.tabBar.isHidden = true
            navigationController?.setNavigationBarHidden(true, animated: false)

            adapter = SwiftUIAdapter(view: contentView, parent: self, backgroundColor: .systemBackground)
            let uiView = adapter!.uiView
            uiView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(uiView)

            NSLayoutConstraint.activate([
                uiView.topAnchor.constraint(equalTo: view.topAnchor),
                uiView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                uiView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                uiView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        }
    }

    func displayEmptyState(withType type: EmptyStateType, onView superview: UIView? = nil) {
        emptyStateAdapter = SwiftUIAdapter(view: EmptyStateView(title: type.title, subtitle: type.subtitle, imageName: type.imageName), parent: self, backgroundColor: .systemBackground)
        let uiView = emptyStateAdapter!.uiView
        uiView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(uiView)

        if let superview {
            NSLayoutConstraint.activate([
                uiView.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                uiView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                uiView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            ])

        } else {
            NSLayoutConstraint.activate([
                uiView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                uiView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                uiView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            ])
        }
    }

    func dismissEmtypState() {
        emptyStateAdapter?.uiView.removeFromSuperview()
        emptyStateAdapter = nil
        let views = view.subviews.filter { $0 is WrappedView }
        views.forEach { $0.removeFromSuperview() }
    }

    func displayCoinsCountButton() {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "\(UserSettings.shared.coinsCount)"
        configuration.image = UIImage(named: "CoinIcon")
        configuration.titlePadding = 4
        configuration.imagePadding = 4
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0)
        let button = UIButton(configuration: configuration)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
}
