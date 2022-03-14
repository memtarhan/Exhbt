//
//  Utilities.swift
//  Exhbt
//
//  Created by Steven Worrall on 4/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import CBGPromise

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}



public class PromiseHelper {
    static func futureWithValue<T1, T2>(_ value: T1) -> Future<Result<T1, T2>> {
        let promise = Promise<Result<T1, T2>>()
        promise.resolve(.success(value))
        return promise.future
    }
    
    static func futureWithValue<T1, T2>(_ error: T2) -> Future<Result<T1, T2>> {
        let promise = Promise<Result<T1, T2>>()
        promise.resolve(.failure(error))
        return promise.future
    }
}

class Utilities {
    // https://stackoverflow.com/questions/32022906/how-can-i-convert-including-timezone-date-in-swift
    // to convert gmt date to local timezone
    static let dateFormatter: DateFormatter = {
        let temp = DateFormatter()
        temp.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        temp.timeZone = TimeZone(identifier:"GMT")
        return temp
    }()

    static func getCurrentDateString() -> String {
        let date = Date()
        return dateFormatter.string(from: date)
    }
    
    static func hasNotch() -> Bool {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
    }
    
    static func getReadableExpirationFrom(dateStr: String) -> String? {
        guard let date = dateFormatter.date(from: dateStr),
            let expirationDate = Calendar.current.date(byAdding: .hour, value: AppConstants.competitionLengthHours, to: date)
            else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
        formatter.timeZone = NSTimeZone.local
        return formatter.string(from: expirationDate)
    }
    
    static func defaultUserImageView() -> UIImageView {
        return UIImageView()
    }
    
    static func createStoredImageLink(with ID: String) -> String {
        return AppConstants.imageStoragePrefix + ID + AppConstants.imageExtension
    }
    
    static func getTempImageURL(image: UIImage) -> URL? {
        guard let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TempImage.jpeg") else {
            return nil
        }
        
        do {
            try image.pngData()?.write(to: imageURL)
            return imageURL
        } catch {
            return nil
        }
    }
    
    static func generateUUID() -> String {
        return UUID().uuidString
    }
}

extension Character {
    func toUpper() -> Character {
        return Character(String(self).uppercased())
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
