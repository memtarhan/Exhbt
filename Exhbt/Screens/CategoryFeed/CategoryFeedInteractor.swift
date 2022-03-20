//
//  CategoryFeedInteractor.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 20/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol CategoryFeedInteractor: AnyObject {
    var presenter: CategoryFeedPresenter? { get set }
}

class CategoryFeedInteractorImpl: CategoryFeedInteractor {
    var presenter: CategoryFeedPresenter?
}
