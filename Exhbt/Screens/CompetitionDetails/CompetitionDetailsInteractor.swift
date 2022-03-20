//
//  CompetitionDetailsInteractor.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 20/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol CompetitionDetailsInteractor: AnyObject {
    var presenter: CompetitionDetailsPresenter? { get set }
}

class CompetitionDetailsInteractorImpl: CompetitionDetailsInteractor {
    var presenter: CompetitionDetailsPresenter?
}
