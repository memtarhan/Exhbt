//
//  PostsViewModel.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class PostsViewModel: NSObject, ViewModel {
    var model: PostsModel!

    typealias snapshotType = NSDiffableDataSourceSnapshot<EventPostSection, DisplayModel>
    private var snapshot = snapshotType()

    @Published var shouldDisplayEmptyState = PassthroughSubject<Void, Never>()
    @Published var snapshotPublisher = PassthroughSubject<snapshotType, Never>()
    @Published var event = PassthroughSubject<EventDisplayModel, Never>()
    @Published var displayFailedToDelete = PassthroughSubject<Void, Never>()

    private var currentPage = 0
    var eventId: Int?

    override init() {
        snapshot.appendSections(EventPostSection.allCases)
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLikedNotification), name: .newPostLikeAvailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDislikedNotification), name: .newPostDislikeAvailableNotification, object: nil)
    }

    func refresh() {
        currentPage = 0
        snapshot.deleteSections([.main])
        snapshot.appendSections([.main])
        load()
    }

    func loadEventDetails() {
        guard let eventId else { return }

        Task {
            do {
                let response = try await model.getEventDetails(forEvent: eventId)
                event.send(EventDisplayModel.from(response: response))

            } catch {
                debugLog(self, error)
            }
        }
    }

    func getAspectRatio(atIndexPath indexPath: IndexPath) -> Double {
        guard indexPath.row < snapshot.itemIdentifiers(inSection: .main).count else { return 1 }
        let item = snapshot.itemIdentifiers(inSection: .main)[indexPath.row] as! PostDisplayModel
        return item.aspectRatio
    }

    func load() {
        guard let eventId else { return }
        currentPage += 1

        Task {
            do {
                let posts = try await model.get(forEvent: eventId, page: currentPage)
                let displayModels = posts.map { PostDisplayModel(withResponse: $0) }

                snapshot.appendItems(displayModels, toSection: .main)
                snapshotPublisher.send(snapshot)

                if self.snapshot.itemIdentifiers(inSection: .main).isEmpty {
                    self.shouldDisplayEmptyState.send()
                }

            } catch {
                debugLog(self, error)
            }
        }
    }

    func delete(post: PostDisplayModel) {
        Task {
            do {
                try await model.delete(post: post)
                snapshot.deleteItems([post])
                snapshotPublisher.send(snapshot)

            } catch {
                debugLog(self, "could not delete post with id: \(post.id)")
                displayFailedToDelete.send()
            }
        }
    }

    func post(asset: CCAsset) {
        guard let eventId else { return }

        Task {
            do {
                let post = try await model.post(eventId: eventId, asset: asset)

                var interaction: PostInteractionType?

                if let postInteraction = post.interaction {
                    interaction = PostInteractionType(withResponse: postInteraction)
                }

                let newModel = PostDisplayModel(id: post.id,
                                                image: asset.image,
                                                imageURL: nil,
                                                videoURL: asset.videoURL,
                                                aspectRatio: asset.aspectRatio,
                                                likesCount: post.likesCount,
                                                dislikesCount: post.dislikesCount,
                                                isOwn: true,
                                                eventId: eventId,
                                                interaction: interaction)

                if let firstItem = snapshot.itemIdentifiers(inSection: .main).first {
                    snapshot.insertItems([newModel], beforeItem: firstItem)

                } else {
                    /// Snapshot is empty
                    snapshot.appendItems([newModel], toSection: .main)
                }

                snapshotPublisher.send(snapshot)

            } catch {
                debugLog(self, error)
            }
        }
    }

    func willDisplayItem(atIndexPath indexPath: IndexPath) {
        if indexPath.row == snapshot.itemIdentifiers(inSection: .main).count - 1 {
            // Load more
            load()
        }
    }
}

extension PostsViewModel: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        _ = task.progress.observe(\.completedUnitCount) { progress, _ in
            debugLog(self, "PROGRESS completedUnitCount - \(progress.completedUnitCount)")
        }

        _ = task.progress.observe(\.fractionCompleted) { progress, _ in
            debugLog(self, "PROGRESS fractionCompleted - \(progress.fractionCompleted)")
        }

//        _ = task.progress.observe(\.fileCompletedCount) { progress, _ in
//            debugLog(self, "PROGRESS fileCompletedCount - \(progress.fileCompletedCount)")
//        }

        let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            print(progress.fractionCompleted)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        debugLog(self, "totalBytesSent: \(totalBytesSent) - totalBytesExpectedToSend: \(totalBytesExpectedToSend)")
    }
}

private extension PostsViewModel {
    @objc
    func handleLikedNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let postId = userInfo["postId"] as? Int {
            debugLog(self, "handleLikedNotification forPost: \(postId)")
            Task(priority: .background) {
                try? await model.like(postId: postId)
            }
        }
    }

    @objc
    func handleDislikedNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let postId = userInfo["postId"] as? Int {
            debugLog(self, "handleDislikedNotification forPost: \(postId)")
            Task(priority: .background) {
                try? await model.dislike(postId: postId)
            }
        }
    }
}
