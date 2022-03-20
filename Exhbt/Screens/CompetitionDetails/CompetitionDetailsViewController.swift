//
//  CompetitionDetailsViewController.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 20/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol CompetitionDetailsViewController: Injectable {
    var presenter: CompetitionDetailsPresenter? { get set }
}

class CompetitionDetailsViewControllerImpl: UIViewController {
    var presenter: CompetitionDetailsPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func injectDependencies() {
        let presenter: CompetitionDetailsPresenter = CompetitionDetailsPresenterImpl()
        let interactor: CompetitionDetailsInteractor = CompetitionDetailsInteractorImpl()
        let router: CompetitionDetailsRouter = CompetitionDetailsRouterImpl()
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

// MARK: - CompetitionDetailsViewController

extension CompetitionDetailsViewControllerImpl: CompetitionDetailsViewController {
}
