//
//  SwiftUI+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 09/11/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import SwiftUI
import UIKit

struct UIHostingControllerPresenter {
    init(_ hostingControllerPresenter: UIViewController) {
        self.hostingControllerPresenter = hostingControllerPresenter
    }

    private unowned var hostingControllerPresenter: UIViewController
    func dismiss() {
        if let presentedViewController = hostingControllerPresenter.presentedViewController, !presentedViewController.isBeingDismissed { // otherwise an ancestor dismisses hostingControllerPresenter - which we don't want.
            hostingControllerPresenter.dismiss(animated: true, completion: nil)
        }
    }
}

private enum UIHostingControllerPresenterEnvironmentKey: EnvironmentKey {
    static let defaultValue: UIHostingControllerPresenter? = nil
}

extension EnvironmentValues {
    /// An environment value that attempts to extend `presentationMode` for case where
    /// view is presented via `UIHostingController` so dismissal through
    /// `presentationMode` doesn't work.
    var uiHostingControllerPresenter: UIHostingControllerPresenter? {
        get { self[UIHostingControllerPresenterEnvironmentKey.self] }
        set { self[UIHostingControllerPresenterEnvironmentKey.self] = newValue }
    }
}

struct SwiftUIView: View {
    @Environment(\.uiHostingControllerPresenter) private var uiHostingControllerPresenter

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button("Dismiss") {
                        uiHostingControllerPresenter?.dismiss()
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}

class SwiftUIExampleViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Presenting a SwiftUI View with dismissable action
        let view = SwiftUIView().environment(\.uiHostingControllerPresenter, UIHostingControllerPresenter(self))
        let viewController = UIHostingController(rootView: view)
        present(viewController, animated: true, completion: nil)

//        let view = SwiftUIView().environment(\.uiHostingControllerPresenter, UIHostingControllerPresenter(self))
//        let destination = UIHostingController(rootView: view)
//
//        destination.modalPresentationStyle = .pageSheet
//
//        if let sheet = destination.sheetPresentationController {
//            sheet.detents = [.medium()]
//            sheet.largestUndimmedDetentIdentifier = .medium
//            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//            sheet.prefersEdgeAttachedInCompactHeight = true
//            sheet.prefersGrabberVisible = true
//            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
//        }
//        present(destination, animated: true, completion: nil)
    }
}

// MARK: - Boolean

/// - not value on a boolean state
extension Binding where Value == Bool {
    var not: Binding<Value> {
        Binding<Value>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}

// MARK: - SwiftUI

extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.dropLast())
            }
        }
        return self
    }
}
