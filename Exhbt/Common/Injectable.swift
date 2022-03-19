//
//  Injectable.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 19/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

protocol Injectable: AnyObject {
    func injectDependencies()
}
