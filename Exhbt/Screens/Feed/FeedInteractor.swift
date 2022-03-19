//
//  FeedInteractor.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 03/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol FeedInteractor: AnyObject {
    var presenter: FeedPresenter? { get set }
}

class FeedInteractorImpl: FeedInteractor {
    var presenter: FeedPresenter?
}
