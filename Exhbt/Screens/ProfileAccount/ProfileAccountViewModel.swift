//
//  ProfileAccountViewModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 08/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Kingfisher
import Photos
import UIKit

enum ProfileItemType {
    case name
    case username
    case aboutMe
    case voteStyle
    case email
    case loginOption
    case password
    case delete

    func displayName() -> String {
        switch self {
        case .name:
            return "Name"
        case .username:
            return "Username"
        case .aboutMe:
            return "About me"
        case .voteStyle:
            return "Vote Style"
        case .email:
            return "Email Adress"
        case .loginOption:
            return "Log In Options"
        case .password:
            return "Password"
        case .delete:
            return "Delete Account..."
        }
    }
}

struct ProfileAccountData {
    let section: String?
    var items: [ProfileItem]
    let headerHeight: CGFloat
}

struct ProfileItem {
    let type: ProfileItemType
    var subtitle: String?
    var icon: UIImage?
    init(type: ProfileItemType, subtitle: String? = nil, icon: UIImage? = nil) {
        self.type = type
        self.subtitle = subtitle
        self.icon = icon
    }
}

// TODO: Refactor this
class ProfileAccountViewModel {
    @Published var addedAsset = CurrentValueSubject<CCAsset?, Never>(nil)
    @Published var updateTableView = CurrentValueSubject<CGFloat?, Never>(nil)
    @Published var deletedAccountPublisher = PassthroughSubject<Void, Error>()

    var model: ProfileAccountModel!
    var view: ProfileAccountViewController!
    private var cancellables: Set<AnyCancellable> = []
    fileprivate let imageManager = PHCachingImageManager()

    var isProfileImage = false
    var profileList = [
        ProfileAccountData(
            section: "PROFILE",
            items: [
                ProfileItem(type: .name),
                ProfileItem(type: .username),
                ProfileItem(type: .aboutMe),
                ProfileItem(type: .voteStyle),
            ],
            headerHeight: 40
        ),
        ProfileAccountData(
            section: "ACCOUNT",
            items: [
                ProfileItem(type: .email),
                ProfileItem(type: .loginOption, subtitle: "Apple"),
//                ProfileItem(type: .password, subtitle: "Change Password") //MARK: - For now there no need password
            ],
            headerHeight: 40
        ),
        ProfileAccountData(
            section: nil,
            items: [
                ProfileItem(type: .delete),
            ],
            headerHeight: 0
        ),
    ]

    init() {
        addedAsset
            .receive(on: DispatchQueue.main)
            .sink { [weak self] asset in
                guard let self = self,
                      let asset = asset else { return }
                if self.isProfileImage {
                    self.updateProfilePhoto(asset: asset)
                }
            }
            .store(in: &cancellables)
    }

    func delete() {
        Task {
            do {
                try await model.delete()
                UserSettings.shared.clearAllUserDefaults()
                deletedAccountPublisher.send(completion: .finished)

            } catch {
                deletedAccountPublisher.send(completion: .failure(error))
            }
        }
    }

    private func updateProfilePhoto(asset: CCAsset) {
        Task {
            _ = try await self.model.updateProfilePhoto(asset: asset)
            let group = DispatchGroup()
            if let profilePhotoFull = UserSettings.shared.profilePhotoFull {
                group.enter()
                KingfisherManager.shared.cache.removeImage(forKey: profilePhotoFull) {
                    group.leave()
                }
            }
            if let profilePhotoThumbnail = UserSettings.shared.profilePhotoThumbnail {
                group.enter()
                KingfisherManager.shared.cache.removeImage(forKey: profilePhotoThumbnail) {
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    NotificationCenter.default.post(name: .didUpdateProfile, object: nil)
                }
            }
        }
    }

    func updateUserProfile(profile: UserResponse? = nil) {
        var height: CGFloat = 0
        for section in 0 ..< profileList.count {
            height += 55
            for row in 0 ..< profileList[section].items.count {
                height += 44
                let type = profileList[section].items[row].type
                switch type {
                case .name:
                    profileList[section].items[row].subtitle = UserSettings.shared.fullName
                case .username:
                    if let username = UserSettings.shared.username {
                        profileList[section].items[row].subtitle = "@\(username)"
                    }
                case .aboutMe:
                    profileList[section].items[row].subtitle = UserSettings.shared.biography
                case .email:
                    profileList[section].items[row].subtitle = UserSettings.shared.email
                    break
                case .voteStyle:
                    profileList[section].items[row].icon = UserSettings.shared.voteStyle?.thumbsImage
                case .loginOption:
                    break
                case .password:
                    break
                case .delete:
                    break
                }
            }
        }
        updateTableView.send(height)
    }
}
