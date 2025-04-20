//
//  ScreenshotDisplayModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 15/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class ReportBugModel {

}

class ReportScreenshotDisplayModel: NSObject {
    var image: UIImage?
    var name: String?
    var size: String?
}

enum ReportSection: CaseIterable {
    case screenshot
}
