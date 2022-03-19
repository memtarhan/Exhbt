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
}

class FeedRouterImpl: FeedRouter {
    var view: FeedViewController?
}
