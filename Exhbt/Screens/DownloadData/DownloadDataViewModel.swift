//
//  DownloadDataViewModel.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 09/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit
import Combine

class DownloadDataViewModel {
    
    var view: DownloadDataViewController!
    @Published var checkRequestDownloadEnable = PassthroughSubject<Bool, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        checkRequestDownloadEnable.sink { [weak self] values in
            guard let self = self else { return }
            let showEmailLabel = self.view.emailTextField.text?.count ?? 0 > 0
            if self.view.emailTextField.text?.isValidEmail ?? false {
                self.view.requestDownloadButton.backgroundColor = .systemBlue
                self.view.requestDownloadButton.isEnabled = true
            } else {
                self.view.requestDownloadButton.backgroundColor = .systemGray4
                self.view.requestDownloadButton.isEnabled = false
            }
            self.view.emailLabel.alpha = showEmailLabel ? 1 : 0
        }
        .store(in: &cancellables)
    }
}
