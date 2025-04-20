//
//  InviteViewModel.swift
//  Exhbt
//
//  Created by Adem Tarhan on 7.10.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Contacts
import Foundation
import UIKit

class InviteViewModel {
    var model: InviteModel!

    @Published var contacts = CurrentValueSubject<[DisplayModel], Never>([])
    @Published var friends = CurrentValueSubject<[DisplayModel], Never>([])
    @Published var link = PassthroughSubject<String?, Never>()
    @Published var shouldDisplayError = PassthroughSubject<String, Never>()
    @Published var shouldStopLoading = PassthroughSubject<Void, Never>()
    @Published var showOpenSettings = PassthroughSubject<Bool, Never>()

    private var invitees = [DisplayModel]()

    private var shouldFetch = true
    private var currentPage = 0
    private let selectionLimit = 7
    var selectionReachedLimit: Bool {
        invitees.count > selectionLimit
    }

    func handleShareLink(forEvent eventId: Int) {
        Task {
            do {
                let response = try await self.model.getShareInvitation(forEvent: eventId)
                self.link.send(response.link)
            } catch {
                debugLog(self, "Failed to fetch share link for exhbt \(error)")
            }
        }
    }

    func sendInvitations(forEvent eventId: Int) {
        let contacts = invitees.filter { $0 is ContactDisplayModel } as! [ContactDisplayModel]
        let friends = invitees.filter { $0 is FollowingContactDisplayModel } as! [FollowingContactDisplayModel]

        Task {
            do {
                self.shouldStopLoading.send()

                if !contacts.isEmpty {
                    _ = try await self.model.invite(invitees: contacts, eventId: eventId)
                }

                if !friends.isEmpty {
                    _ = try await self.model.invite(invitees: friends, eventId: eventId)
                }

            } catch {
                self.shouldDisplayError.send("Failed to send invitations")
                self.shouldStopLoading.send()
            }
        }
    }

    func addInvitee(contact: DisplayModel) {
        invitees.append(contact)
    }

    func removeInvitee(contact: DisplayModel) {
        if let index = invitees.firstIndex(of: contact) {
            invitees.remove(at: Int(index))
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
//        invitees.append(myContact)

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
}
