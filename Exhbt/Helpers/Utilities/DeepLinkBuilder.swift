//
//  DeepLinkBuilder.swift
//  Exhbt
//
//  Created by Shouvik Paul on 6/6/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import Foundation

class DeepLinkBuilder {
    // deepLinkStr should be in the form of: "https://getexhbt.com/[invite, competition, user]/id"
    private static func createFirebaseDeepLink(for deepLinkStr: String) -> URL? {
        let firebaseDeepLinkUrlString = AppConstants.deepLinkUriPrefix +
            "?link=" + deepLinkStr +
            "&ibi=com.exhbtmain.exhbt" + "&isi=1509591573" + "&ifl=https://www.getexhbt.com"
        return URL(string: firebaseDeepLinkUrlString)
    }
    
    static func createInviteLink(for competitionID: String) -> URL? {
        let link = AppConstants.baseUrl + "invite/" + competitionID
        return createFirebaseDeepLink(for: link)
    }
    
    static func createAppLink() -> URL? {
        return createFirebaseDeepLink(for: AppConstants.baseUrl)
    }
}
