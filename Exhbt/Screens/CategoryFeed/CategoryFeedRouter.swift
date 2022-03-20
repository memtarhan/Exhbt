//
//  CategoryFeedRouter.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 20/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol CategoryFeedRouter: AnyObject {
    var view: CategoryFeedViewController? { get set }
}

class CategoryFeedRouterImpl: CategoryFeedRouter {
    var view: CategoryFeedViewController?
}
