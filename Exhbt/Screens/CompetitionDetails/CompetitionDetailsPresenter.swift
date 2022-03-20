//
//  CompetitionDetailsPresenter.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 20/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol CompetitionDetailsPresenter: AnyObject {
    var view: CompetitionDetailsViewController? { get set }
    var interactor: CompetitionDetailsInteractor? { get set }
    var router: CompetitionDetailsRouter? { get set }
}

class CompetitionDetailsPresenterImpl: CompetitionDetailsPresenter {
    var view: CompetitionDetailsViewController?
    var interactor: CompetitionDetailsInteractor?
    var router: CompetitionDetailsRouter?
}
