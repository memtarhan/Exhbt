//
//  SearchInteractor.swift
//  Exhbt
//
//  Created by Shouvik Paul on 10/19/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import CoreData

protocol SearchInteractorDelegate: AnyObject {
    func didReceiveAllUsers(_ users: [User])
    func errorReceivingAllUsers(_ error: Error)
    func didReceiveUser(_ user: User)
    func errorReceivingUser(_ error: Error)
}

struct RecentSearch {
    let userID: String
    let name: String
}

class SearchInteractor {
    
    static let RecentSearchEntity = "RecentSearchEntity"
    
    let userRepo = UserRepository()
    weak var delegate: SearchInteractorDelegate?
    
    func getAllUsers() {
        userRepo.getAllUsers().then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let users):
                self.delegate?.didReceiveAllUsers(users)
            case .failure(let error):
                self.delegate?.errorReceivingAllUsers(error)
            }
        }
    }
    
    func getUser(by userID: String) {
        userRepo.getUser(by: userID).then {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.delegate?.didReceiveUser(user)
            case .failure(let error):
                self.delegate?.errorReceivingUser(error)
            }
        }
    }
    
    func getRecentSearches() -> [RecentSearch] {
        var searches = [RecentSearch]()
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return searches
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SearchInteractor.RecentSearchEntity)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            result.forEach { data in
                guard let obj = data as? NSManagedObject,
                    let userID = obj.value(forKey: UserField.userID.rawValue) as? String,
                    let name = obj.value(forKey: UserField.name.rawValue) as? String else {
                        return
                }
                
                searches.append(RecentSearch(userID: userID, name: name))
            }
            
        } catch {
            print("Failed to get recent searches: \(error)")
        }
        
        return searches
    }
    
    func saveRecentSearch(_ newSearch: RecentSearch) {
        guard newSearch.name != "", let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        
        var searches = [newSearch]
        searches += getRecentSearches().filter { return $0.userID != newSearch.userID }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentSearchEntity")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            result.forEach { data in
                guard let obj = data as? NSManagedObject else { return }
                context.delete(obj)
            }
        } catch {
            print("Failed to delete searches. Not appending new search. \(error)")
            return
        }
        
        for search in searches {
            let searchObj = NSEntityDescription.insertNewObject(forEntityName: SearchInteractor.RecentSearchEntity, into: context)
            searchObj.setValue(search.userID, forKey: UserField.userID.rawValue)
            searchObj.setValue(search.name, forKey: UserField.name.rawValue)
        }
        do {
            try context.save()
            print("Saved recent search: \(newSearch)")
        } catch {
            print("Error saving recent searches: \(error)")
        }
    }
    
    func removeSearch(_ search: RecentSearch) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentSearchEntity")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            for data in results {
                if let obj = data as? NSManagedObject,
                    let userID = obj.value(forKey: UserField.userID.rawValue) as? String,
                    userID == search.userID {
                    context.delete(obj)
                    print("Deleted search \(search)")
                    break
                }
            }
        } catch {
            print("Failed to delete search \(search). error: \(error)")
        }
        
        do {
            try context.save()
            print("Deletion saved")
        } catch {
            print("Error saving recent search context after delete: \(error)")
        }
    }
}
