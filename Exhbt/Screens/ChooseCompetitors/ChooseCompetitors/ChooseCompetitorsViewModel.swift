//
//  ChooseCompetitorsViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 08/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import Contacts
import UIKit

class ChooseCompetitorsViewModel {
    var model: ChooseCompetitorsModel!

    private let selectionLimit = 7
    var selectionReachedLimit: Bool {
        competitors.value.count > selectionLimit
    }

    private var shouldFetch = true

    @Published var exhbtId = CurrentValueSubject<Int, Never>(-1)
    @Published var contacts = CurrentValueSubject<[DisplayModel], Never>([])
    @Published var friends = CurrentValueSubject<[DisplayModel], Never>([])
    @Published var link = PassthroughSubject<String?, Never>()
    @Published var competitors = CurrentValueSubject<[DisplayModel], Never>([])
    @Published var shouldDisplayError = PassthroughSubject<String, Never>()
    @Published var shouldStopLoading = PassthroughSubject<Void, Never>()
    @Published var showOpenSettings = PassthroughSubject<Bool, Never>()

    private var currentPage = 0

    func handleShareLink(forExhbt exhbtId: Int) {
        Task {
            do {
                let response = try await self.model.getShareInvitation(forExhbt: exhbtId)
                self.link.send(response.link)
            } catch {
                debugLog(self, "Failed to fetch share link for exhbt \(error)")
            }
        }
    }

    func sendInvitations(forExhbt exhbtId: Int) {
        let contacts = competitors.value.filter { $0 is ContactDisplayModel } as! [ContactDisplayModel]
        let friends = competitors.value.filter { $0 is FollowingContactDisplayModel } as! [FollowingContactDisplayModel]

        Task {
            do {
                _ = try await self.model.invite(competitors: contacts, exhbtId: exhbtId)
                _ = try await self.model.invite(competitors: friends, exhbtId: exhbtId)
                self.shouldStopLoading.send()

            } catch {
                self.shouldDisplayError.send("Failed to send invitations")
                self.shouldStopLoading.send()
            }
        }
    }

    func addCompetitor(contact: DisplayModel) {
        competitors.value.append(contact)
    }

    func removeCompetitor(contact: DisplayModel) {
        if let index = competitors.value.firstIndex(of: contact) {
            competitors.value.remove(at: Int(index))
        }
    }

    func loadFriends() {
        currentPage += 1

        Task {
            let followings = try await model.followings(page: self.currentPage)
            shouldFetch = !followings.isEmpty
            let friends = followings.map {
                FollowingContactDisplayModel(id: $0.id, userId: $0.id, fullName: $0.username, imageURL: $0.profilePhoto)
            }

            self.friends.value.append(contentsOf: friends)
        }
    }

    func fetchContacts() {
//        let myContact = ContactDisplayModel(id: UserSettings.shared.id, imageURL: UserSettings.shared.profilePhotoThumbnail)
//        competitors.value.append(myContact)

        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                var contacts = [ContactDisplayModel]()

                DispatchQueue.global(qos: .background).async {
                    try? store.enumerateContacts(with: request, usingBlock: { contact, _ in
                        var image: UIImage?
                        if let data = contact.imageData {
                            image = UIImage(data: data)
                        }

                        contacts.append(ContactDisplayModel(id: UUID().hashValue,
                                                            fullName: "\(contact.givenName) \(contact.familyName)",
                                                            image: image,
                                                            phoneNumber: contact.phoneNumbers.first?.value.stringValue))
                    })

                    contacts.sort { ($0.fullName ?? "") < ($1.fullName ?? "") }
                    self.contacts.send(contacts)
                }
            } else {
                self.showOpenSettings.send(true)
            }
        }
    }

    func willDisplayItem(atIndexPath indexPath: IndexPath) {
        if (indexPath.row == friends.value.count - 1) && shouldFetch {
            loadFriends()
        }
    }
}
