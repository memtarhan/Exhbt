//
//  CategoryFeedViewController.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 20/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol CategoryFeedViewController: Injectable {
    var presenter: CategoryFeedPresenter? { get set }

    var category: Category? { get set }
}

class CategoryFeedViewControllerImpl: UIViewController {
    var presenter: CategoryFeedPresenter?

    var category: Category?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func injectDependencies() {
        let presenter: CategoryFeedPresenter = CategoryFeedPresenterImpl()
        let interactor: CategoryFeedInteractor = CategoryFeedInteractorImpl()
        let router: CategoryFeedRouter = CategoryFeedRouterImpl()
        presenter.view = self
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.view = self

        self.presenter = presenter
    }

    private func setup() {
        navigationItem.title = category?.title
    }
}

// MARK: - CategoryFeedViewController

extension CategoryFeedViewControllerImpl: CategoryFeedViewController {
}
