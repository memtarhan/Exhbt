//
//  UserDefaultsRepository.swift
//  Exhbt
//
//  Created by Shouvik Paul on 5/6/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation

class UserDefaultsRepository {
    let defaults: UserDefaults
    
    init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }
    
    func getBool(for key: UserDefaultsKeys) -> Bool {
        return defaults.bool(forKey: key.rawValue)
    }
    
    func setBool(_ value: Bool, for key: UserDefaultsKeys) {
        defaults.set(value, forKey: key.rawValue)
        synchronize()
    }
    
    func getString(for key: UserDefaultsKeys) -> String? {
        return defaults.string(forKey: key.rawValue)
    }
    
    func setString(_ value: String?, for key: UserDefaultsKeys) {
        defaults.set(value, forKey: key.rawValue)
        synchronize()
    }
    
    private func synchronize() {
        defaults.synchronize()
    }
}

enum UserDefaultsKeys: String {
    case hasSeenOnboarding
    case userID
    case hasCreatedACompetition
    case hasRecievedInitalCoins
}
