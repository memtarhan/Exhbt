//
//  ReportType.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 04/05/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

enum ReportType: String, CaseIterable {
    case report1 = "It’s spam"
    case report2 = "Racism, discrimination, or insults"
    case report3 = "Hate speech, violence, or threats"
    case report4 = "Nudity"
    case report5 = "Goes against my beliefs or values"
    case report0 = "Other"
}
