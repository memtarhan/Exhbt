//
//  APICallable.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 22/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

protocol APICallable {
    var baseURL: String { get } // Base URL
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
    var urlSession: URLSession { get }

    func securedSession(withToken token: String) -> URLSession
    func handleDataTask<T: APIResponse>(_ session: URLSession, from url: URL) async throws -> T
    func handleDataTask<T: APIResponse>(_ session: URLSession, for urlRequest: URLRequest) async throws -> T
    func handleUploadTask(withImage image: UIImage, url: URL, token: String, paramaters: [String: String]?, task: URLSessionTaskDelegate?) async throws -> UploadResponse
    func handleUploadTask(withVideo video: URL, url: URL, token: String, paramaters: [String: String]?, task: URLSessionTaskDelegate?) async throws -> UploadResponse
}

extension APICallable {
    var baseURL: String { BaseURLs.stagingBaseURL }
    var decoder: JSONDecoder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .gmt
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }

    var encoder: JSONEncoder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .gmt
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.keyEncodingStrategy = .convertToSnakeCase

        return encoder
    }

    var urlSession: URLSession {
        URLSession.shared
    }

    func securedSession(withToken token: String) -> URLSession {
        let authValue = "Bearer \(token)"

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpAdditionalHeaders = ["Authorization": authValue]
        let session = URLSession(configuration: sessionConfig, delegate: self as? URLSessionDelegate, delegateQueue: nil)

        return session
    }

    func handleDataTask<T: APIResponse>(_ session: URLSession, from url: URL) async throws -> T {
        let (data, _) = try await session.data(from: url)
        if let prettyJSON = data.prettyJSON {
            debugLog(self, prettyJSON)
        }
        return try decoder.decode(T.self, from: data)
    }

    func handleDataTask<T: APIResponse>(_ session: URLSession, for urlRequest: URLRequest) async throws -> T {
        let (data, _) = try await session.data(for: urlRequest)
        if let prettyJSON = data.prettyJSON {
            debugLog(self, prettyJSON)
        }
        return try decoder.decode(T.self, from: data)
    }

    func handleUploadTask(withImage image: UIImage, url: URL, token: String, paramaters: [String: String]? = nil, task: URLSessionTaskDelegate? = nil) async throws -> UploadResponse {
        let boundary = generateBoundary()
        var request = URLRequest(url: url)
        guard let mediaImage = Media(withImage: image, forKey: "fileobject") else { throw HTTPError.invalidEndpoint }
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "X-User-Agent": "ios",
            "Accept-Language": "en",
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
        ]
        let dataBody = createDataBody(withParameters: paramaters, media: [mediaImage], boundary: boundary)
        request.httpBody = dataBody
        debugLog(self, "willUploadImage")
        let (data, _) = try await securedSession(withToken: token).data(for: request, delegate: task)
        let response = try decoder.decode(UploadResponse.self, from: data)
        debugLog(self, "didUploadImage", response)
        return response
    }

    func handleUploadTask(withVideo video: URL, url: URL, token: String, paramaters: [String: String]? = nil, task: URLSessionTaskDelegate? = nil) async throws -> UploadResponse {
        let boundary = generateBoundary()
        var request = URLRequest(url: url)
        guard let mediaImage = Media(withVideo: video, forKey: "fileobject") else { throw HTTPError.invalidEndpoint }
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "X-User-Agent": "ios",
            "Accept-Language": "en",
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
        ]
        let dataBody = createDataBody(withParameters: paramaters, media: [mediaImage], boundary: boundary)
        request.httpBody = dataBody
        debugLog(self, "willUploadVideo")
        let (data, _) = try await securedSession(withToken: token).data(for: request, delegate: task)
        let response = try decoder.decode(UploadResponse.self, from: data)
        debugLog(self, "didUploadVideo", response)
        return response
    }

    private func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }

    private func createDataBody(withParameters params: [String: String]?, media: [Media]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}

// TODO: Create environments

struct BaseURLs {
    // TODO: Move it to strings
    static let stagingBaseURL = "https://exhbt-staging.herokuapp.com"
    static let betaBaseURL = "https://exhbt-beta.herokuapp.com"
    static let testBaseURL = "https://exhbt-test.herokuapp.com"
    static let localBaseURL = "http://127.0.0.1:8000"
    static let productionBaseURL = "https://exhbt-production-5b069796cdbc.herokuapp.com"
}

struct BaseURL {
    static var shared: String {
        BaseURLs.stagingBaseURL
    }
}
