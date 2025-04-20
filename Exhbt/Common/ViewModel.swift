//
//  ViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 05/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation

protocol ViewModel {
    func registerNotifications()
    func load()
}

protocol SearchableViewModel {
    func searchBarDidClear()
    func searchBarDidCancel()
    func searchBarDidSearch(keyword: String?)
}
