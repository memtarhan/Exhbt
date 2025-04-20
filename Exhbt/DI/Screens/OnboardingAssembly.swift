//
//  OnboardingAssembly.swift
//  Exhbt
//
//  Created by hilmideprem on 18.08.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import SwiftUI
import Swinject
import UIKit

class OnboardingAssembly: Assembly {
    func assemble(container: Container) {
        container.register(OnboardingViewController.self) { _ in
            OnboardingViewController()
        }
    }
}
