//
//  ImageRepository.swift
//  Exhbt
//
//  Created by Shouvik Paul on 6/29/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation
import CBGPromise

enum ImageSize: String, CaseIterable {
    case avatar
    case tiny
    case small
    // TODO: add more or change size if necessary
    
    var identifier: String {
        "_\(self.rawValue)_\(width)"
    }
    
    var width: Int {
        switch self {
        case .avatar:
            return 50
        case .tiny:
            return 100
        case .small:
            return 414
        }
    }
    
    static func smallest(_ size: ImageSize) -> [ImageSize] {
        var sizes: [ImageSize] = []
        var returnSize = false
        for s in ImageSize.allCases {
            if s == size {
                returnSize = true
            }
            if returnSize {
                sizes.append(s)
            }
        }
        return sizes
    }
}

class ImageRepository {
    
    func uploadImage(_ image: UIImage?, with ID: String? = nil)  -> Future<Result<String, Error>> {
        guard let image = image?.fixOrientation(),
              let localFile = Utilities.getTempImageURL(image: image) else { return PromiseHelper.futureWithValue(CompetitionError.parseImageError)
        }
        
        let promise = Promise<Result<String, Error>>()
        
        let imageID = ID ?? Utilities.generateUUID()
        let storageRef = storage.reference(withPath: Utilities.createStoredImageLink(with: imageID))
        let uploadTask = storageRef.putFile(from: localFile)
        
        uploadTask.observe(.success) { snapshot in
            print("uploaded imageID \(imageID)")
            promise.resolve(.success(imageID))
        }
        
        uploadTask.observe(.failure) { snapshot in
            print("failed to upload imageID \(imageID): \(snapshot.error as NSError?)")
            promise.resolve(.failure(GenericError.imageUploadError))
        }
        
        return promise.future
    }
    
    func getPhoto(with UUID: String) -> Future<Result<URL, Error>>  {
        let storageRef = storage.reference()
        let reference = storageRef.child(Utilities.createStoredImageLink(with: UUID))
        
        let promise = Promise<Result<URL, Error>>()
        
        reference.downloadURL { url, error in
            if let error = error {
                print("Error retrieving image URL: \(error)")
                promise.resolve(.failure(GenericError.notFound))
            } else {
                if let unwrappedURL = url {
                    promise.resolve(.success(unwrappedURL))
                } else {
                    promise.resolve(.failure(GenericError.notFound))
                }
            }
        }
        return promise.future
    }
    
    func uploadImageForRestOfSizes(
        image: UIImage,
        ID: String,
        sizes: [ImageSize]
    ) {
        let index = sizes.count - 1
        
        func startUploading(index: Int) {
            guard index >= 0 else { return }
            let size = sizes[index]
            uploadImage(
                image.resizeImage(newWidth: CGFloat(size.width)),
                with: "\(ID)\(size.identifier)").then {
                    [weak self] _ in
                    guard let _ = self else { return }
                    startUploading(index: index-1)
                }
        }
        
        DispatchQueue.global(qos: .background).async {
            startUploading(index: index)
        }
    }
}
