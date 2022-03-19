//
//  FeedPresenter.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 03/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol FeedPresenter: AnyObject {
    var view: FeedViewController? { get set }
    var interactor: FeedInteractor? { get set }
    var router: FeedRouter? { get set }
}

class FeedPresenterImpl: FeedPresenter {
    var view: FeedViewController?
    var interactor: FeedInteractor?
    var router: FeedRouter?
}
