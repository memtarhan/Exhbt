//
//  ViewControllerFactory.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 19/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

class ViewControllerFactory {
    static let shared: ViewControllerFactory = ViewControllerFactory()

    var feed: FeedViewController {
        let view: FeedViewController = FeedViewControllerImpl(nibName: "FeedViewController", bundle: nil)
        view.injectDependencies()
        return view
    }
}
