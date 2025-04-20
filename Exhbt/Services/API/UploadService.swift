//
//  UploadService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 23/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Photos
import UIKit

protocol UploadServiceProtocol: APIService {
    func upload(asset: CCAsset, forCompetition competitionId: Int) async throws
    func uploadEventCover(image: UIImage, eventId: Int) async throws -> UploadResponse
    func upload(asset: CCAsset, forPost postId: Int, task: URLSessionTaskDelegate?) async throws
}

class UploadService: UploadServiceProtocol {
    
    
    private var token: String? { UserSettings.shared.token }

    func upload(asset: CCAsset, forCompetition competitionId: Int) async throws {
        if let video = asset.videoURL {
            _ = try await uploadToServer(video: video, competitionId: competitionId)

        } else if let image = asset.image {
            _ = try await uploadToServer(image: image, competitionId: competitionId)
        }
    }

    func upload(asset: CCAsset, forPost postId: Int, task: URLSessionTaskDelegate? = nil) async throws {
        if let video = asset.videoURL {
            _ = try await uploadPost(video: video, postId: postId, task: task)

        } else if let image = asset.image {
            _ = try await uploadPost(image: image, postId: postId, task: task)
        }
    }

    private func uploadToServer(image: UIImage, competitionId: Int) async throws -> UploadResponse {
        guard let url = URL.Competition.photo(competitionId: competitionId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let parameters = ["order_ext_id": "jpeg"]
        let response = try await handleUploadTask(withImage: image, url: url, token: token, paramaters: parameters)
        return response
    }

    private func uploadToServer(video: URL, competitionId: Int) async throws -> UploadResponse {
        guard let url = URL.Competition.video(competitionId: competitionId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let parameters = ["order_ext_id": "mov"]
        let response = try await handleUploadTask(withVideo: video, url: url, token: token, paramaters: parameters)
        return response
    }

    func uploadEventCover(image: UIImage, eventId: Int) async throws -> UploadResponse {
        guard let url = URL.Event.coverPhoto(eventId: eventId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let parameters = ["order_ext_id": "mov"]
        let response = try await handleUploadTask(withImage: image, url: url, token: token, paramaters: parameters)
        return response
    }

    func uploadPost(image: UIImage, postId: Int, task: URLSessionTaskDelegate? = nil) async throws -> UploadResponse {
        guard let url = URL.Post.photo(postId: postId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let parameters = ["order_ext_id": "jpeg"]
        let response = try await handleUploadTask(withImage: image, url: url, token: token, paramaters: parameters, task: task)
        return response
    }

    func uploadPost(video: URL, postId: Int, task: URLSessionTaskDelegate? = nil) async throws -> UploadResponse {
        guard let url = URL.Post.video(postId: postId) else { throw HTTPError.invalidEndpoint }
        guard let token else { throw UserError.invalidToken }
        let parameters = ["order_ext_id": "mov"]
        let response = try await handleUploadTask(withVideo: video, url: url, token: token, paramaters: parameters, task: task)
        return response
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

struct Media {
    let key: String
    let fileName: String
    let data: Data
    let mimeType: String

    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        mimeType = "image/jpg"
        fileName = "\(arc4random()).jpeg"

        guard let data = image.jpegData(compressionQuality: 0.5) else { return nil }
        self.data = data
    }

    init?(withVideo video: URL, forKey key: String) {
        self.key = key
        mimeType = "video/mp4"
        fileName = "\(arc4random()).mp4"

        guard let data = try? Data(contentsOf: video) else { return nil }
        self.data = data
    }
}
