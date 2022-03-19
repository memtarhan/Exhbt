//
//  FeedViewController.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 03/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol FeedViewController: Injectable {
    var presenter: FeedPresenter? { get set }
}

class FeedViewControllerImpl: UIViewController {
    var presenter: FeedPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func injectDependencies() {
        let presenter: FeedPresenter = FeedPresenterImpl()
        let interactor: FeedInteractor = FeedInteractorImpl()
        let router: FeedRouter = FeedRouterImpl()
        presenter.view = self
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.view = self

        self.presenter = presenter
    }

    private func setup() {
    }
}

// MARK: - FeedViewController

extension FeedViewControllerImpl: FeedViewController {
}
