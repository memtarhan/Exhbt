//
//  ReportActionService.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 15/06/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class ReportActionService {
    static var shared = ReportActionService()

    @Published private var displayingReportAction = PassthroughSubject<Bool, Never>()
    @Published private var displayingReportPlaceAction = PassthroughSubject<Bool, Never>()
    @Published private var displayingReportForExhbtAction = PassthroughSubject<Bool, Never>()
    @Published private var displayingReportForImageAction = PassthroughSubject<Bool, Never>()

    @Published var reportActionServiceDidFinishReporting = PassthroughSubject<Void, Never>()

    private var cancellables: Set<AnyCancellable> = []

    weak var view: UIViewController?

    private init() {
        displayingReportAction.sink { [weak self] _ in
            guard let self = self else { return }
            self.presentActionSheet()
        }
        .store(in: &cancellables)

        displayingReportPlaceAction.sink { [weak self] _ in
            guard let self = self else { return }
            self.presentPlaceActionSheet()
        }
        .store(in: &cancellables)

        displayingReportForExhbtAction.sink { [weak self] _ in
            guard let self = self else { return }
            self.presentTypeActionSheet(for: "exhbt (competition)")
        }
        .store(in: &cancellables)

        displayingReportForImageAction.sink { [weak self] _ in
            guard let self = self else { return }
            self.presentTypeActionSheet(for: "image")
        }
        .store(in: &cancellables)
    }

    func display(on view: UIViewController) {
        self.view = view
        displayingReportAction.send(true)
    }

    private func presentActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Report…", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.displayingReportPlaceAction.send(true)
        }
        // TODO: - Fix report icon
        actionSheet.addAction(reportAction)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = view?.view
            popoverController.sourceRect = CGRect(x: view?.view.bounds.midX ?? 0, y: view?.view.bounds.midY ?? 0, width: 0, height: 0)
            popoverController.permittedArrowDirections = [] // No arrow for the popover
        }
        view?.present(actionSheet, animated: true, completion: nil)
    }

    private func presentPlaceActionSheet() {
        let actionSheet = UIAlertController(title: "What are you reporting?", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "This exhbt (competition)", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.displayingReportForExhbtAction.send(true)
        }
        actionSheet.addAction(action1)
        let action2 = UIAlertAction(title: "This image", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.displayingReportForImageAction.send(true)
        }
        actionSheet.addAction(action2)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = view?.view
            popoverController.sourceRect = CGRect(x: view?.view.bounds.midX ?? 0, y: view?.view.bounds.midY ?? 0, width: 0, height: 0)
            popoverController.permittedArrowDirections = [] // No arrow for the popover
        }
        view?.present(actionSheet, animated: true, completion: nil)
    }

    private func presentTypeActionSheet(for item: String) {
        let actionSheet = UIAlertController(title: "Why are you reporting this \(item)?", message: nil, preferredStyle: .actionSheet)
        ReportType.allCases.forEach { type in
            let action = UIAlertAction(title: type.rawValue, style: .default) { [weak self] _ in
                guard let self = self else { return }
                debugLog(self, "Reported for \(type.rawValue)")
                // TODO: - Implement reporting
                self.presenResultActionSheet(for: item)
            }
            actionSheet.addAction(action)
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = view?.view
            popoverController.sourceRect = CGRect(x: view?.view.bounds.midX ?? 0, y: view?.view.bounds.midY ?? 0, width: 0, height: 0)
            popoverController.permittedArrowDirections = [] // No arrow for the popover
        }
        view?.present(actionSheet, animated: true, completion: nil)
    }

    private func presenResultActionSheet(for item: String) {
        let actionSheet = UIAlertController(title: "Thanks for reporting this \(item)!", message: nil, preferredStyle: .alert)
        actionSheet.addAction(UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.view = nil
            self.reportActionServiceDidFinishReporting.send()
        })
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = view?.view
            popoverController.sourceRect = CGRect(x: view?.view.bounds.midX ?? 0, y: view?.view.bounds.midY ?? 0, width: 0, height: 0)
            popoverController.permittedArrowDirections = [] // No arrow for the popover
        }
        view?.present(actionSheet, animated: true, completion: nil)
    }
}
