//
//  CategoryFeedPresenter.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 20/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol CategoryFeedPresenter: AnyObject {
    var view: CategoryFeedViewController? { get set }
    var interactor: CategoryFeedInteractor? { get set }
    var router: CategoryFeedRouter? { get set }
}

class CategoryFeedPresenterImpl: CategoryFeedPresenter {
    var view: CategoryFeedViewController?
    var interactor: CategoryFeedInteractor?
    var router: CategoryFeedRouter?
}
