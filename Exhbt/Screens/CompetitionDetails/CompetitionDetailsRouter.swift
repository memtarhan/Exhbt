//
//  CompetitionDetailsRouter.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 20/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol CompetitionDetailsRouter: AnyObject {
    var view: CompetitionDetailsViewController? { get set }
}

class CompetitionDetailsRouterImpl: CompetitionDetailsRouter {
    var view: CompetitionDetailsViewController?
}
