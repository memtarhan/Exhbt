//
//  FollowersInteractor.swift
//  Exhbt
//
//  Created by Steven Worrall on 11/27/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation
import CBGPromise

protocol FollowersInteractorDelegate: AnyObject {
    func didGetFollowers(followers: [User])
    func errorGettingFollowers()
}

class FollowersInteractor {
    weak var delegate: FollowersInteractorDelegate?
    
    let followRepo = FollowRepo()
    let userRepo = UserRepository()
    
    func getFollowers(for userID: String) {
        followRepo.getFollowers(for: userID).then {
            [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let followers):
                self.getUsersFromFollowers(followers: followers)
            case .failure(let error):
                print("Error getting followers for \(userID): \(error)")
                self.delegate?.errorGettingFollowers()
            }
        }
    }
    
    func getUsersFromFollowers(followers: [Follow]) {
        var futures: [Future<User?>] = []
        
        followers.forEach { (follower) in
            let promise = Promise<User?>()
            futures.append(promise.future)
            
            let userID = follower.userID
            
            userRepo.getUser(by: userID).then {
                [weak self] result in
                guard let _ = self else { return }
                
                switch result {
                case .success(let user):
                    promise.resolve(user)
                case .failure(_):
                    promise.resolve(nil)
                }
            }
        }
        
        if futures.count == 0 {
            delegate?.didGetFollowers(followers: [])
            return
        }
        
        Promise<User>.when(futures).then {
            [weak self] rawUsers in
            guard let self = self else { return }

            var users = [User]()
            rawUsers.forEach {
                if let user = $0 { users.append(user) }
            }
            self.delegate?.didGetFollowers(followers: users)
        }
    }

}
