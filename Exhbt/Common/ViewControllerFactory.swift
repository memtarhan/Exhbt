//
//  ViewControllerFactory.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 04/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

class ViewControllerFactory {
    static let shared: ViewControllerFactory = ViewControllerFactory()

    weak var feed: FeedViewController? {
        let view: FeedViewController = FeedViewControllerImpl(nibName: "FeedViewController", bundle: nil)
        view.injectDependencies()
        return view
    }

    weak var competitionDetails: CompetitionDetailsViewController? {
        let view: CompetitionDetailsViewController = CompetitionDetailsViewControllerImpl(nibName: "CompetitionDetailsViewController", bundle: nil)
        view.injectDependencies()
        return view
    }

    weak var categoryFeed: CategoryFeedViewController? {
        let view: CategoryFeedViewController = CategoryFeedViewControllerImpl(nibName: "CategoryFeedViewController", bundle: nil)
        view.injectDependencies()
        return view
    }
}
