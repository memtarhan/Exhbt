//
//  FeedRouter.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 03/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol FeedRouter: AnyObject {
    var view: FeedViewController? { get set }

    func navigateToDetails()
}

class FeedRouterImpl: FeedRouter {
    var view: FeedViewController?

    func navigateToDetails() {
        guard let source = view as? UIViewController,
              let destination = ViewControllerFactory.shared.competitionDetails as? UIViewController else { return }
        source.navigationController?.pushViewController(destination, animated: true)
    }
}
