//
//  NewCompetitionStatusViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 06/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Contacts
import UIKit

enum NewCompetitionStatusType {
    case pub
    case priv
    case contacts

    var title: String {
        switch self {
        case .pub:
            return "You’ve created\na Public Competition"
        case .priv:
            return "You chose to create\na Private Competition"
        case .contacts:
            return "Find Contacts"
        }
    }

    var hasTitleImage: Bool {
        switch self {
        case .pub, .priv:
            return false
        case .contacts:
            return true
        }
    }

    var description: String {
        switch self {
        case .pub:
            return "It means everyone can join. If you want to invite yours friends to this competition, connect your Contacts or chose them from your Friends list."
        case .priv:
            return "This means only people whom you invite may participate. Provide access to Contacts to see your friends on the app so you can challenge them to competitions, and invite anyone else in a few taps."
        case .contacts:
            return "Search your contacts to find your friends on Exhbt or to invite them (these people won’t be contacted yet)."
        }
    }

    var consent: String {
        "We do not store your contacts on our servers and do not send any messages without your consent."
    }

    var consentIcon: UIImage? {
        switch self {
        case .pub, .priv:
            return UIImage(systemName: "info.circle")
        case .contacts:
            return UIImage(systemName: "checkmark.circle")
        }
    }

    var consentColor: UIColor? {
        switch self {
        case .pub, .priv:
            return UIColor(named: "LightGray")
        case .contacts:
            return UIColor(named: "LightGreen")
        }
    }

    var iconColor: UIColor? {
        switch self {
        case .pub, .priv:
            return UIColor(named: "ExhbtLighGray")
        case .contacts:
            return UIColor(named: "ExhbtDarkGreen")
        }
    }

    var accessButtonTitle: String {
        "Access Contacts"
    }

    var createButtonTitle: String {
        switch self {
        case .pub, .contacts:
            return "Maybe later"
        case .priv:
            return "Create a Public Competition "
        }
    }
}

protocol NewCompetitionStatusDelegate {
    func newCompetitionStatusDidDismiss(withSuccess success: Bool)
}

class NewCompetitionStatusViewController: UIViewController, Nibbable {
    @IBOutlet var titleImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var consentView: UIView!
    @IBOutlet var consentLabel: UILabel!
    @IBOutlet var consentIconImageView: UIImageView!

    @IBOutlet var accessButton: UIButton!
    @IBOutlet var createButton: UIButton!

    var type: NewCompetitionStatusType?
    var delegate: NewCompetitionStatusDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    // MARK: - Actions

    @IBAction func didTapAccess(_ sender: Any) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in
            DispatchQueue.main.async {
                self.dismiss(animated: false)
            }
            self.delegate?.newCompetitionStatusDidDismiss(withSuccess: granted)
        }
    }

    @IBAction func didTapDismiss(_ sender: Any) {
        dismiss(animated: true)
    }

    private func setup() {
        guard let type else { return }
        setupLayout(withType: type)

        titleLabel.text = type.title
        descriptionLabel.text = type.description
        consentLabel.text = type.consent
        consentIconImageView.image = type.consentIcon
        consentIconImageView.tintColor = type.iconColor
        accessButton.titleLabel?.text = type.accessButtonTitle
        createButton.titleLabel?.text = type.createButtonTitle
    }

    private func setupLayout(withType type: NewCompetitionStatusType) {
        titleImageView.isHidden = !type.hasTitleImage

        consentView.layer.cornerRadius = 7
        consentView.backgroundColor = type.consentColor

//        accessButton.backgroundColor = .systemBlue
//        accessButton.titleLabel?.textColor = .white
//        accessButton.layer.cornerRadius = 7
//
//        createButton.layer.borderWidth = 1.0
//        createButton.layer.borderColor = UIColor.systemBlue.cgColor
//        createButton.titleLabel?.textColor = .systemBlue
//        createButton.setTitleColor(.systemBlue, for: .normal)
//        createButton.setTitleColor(.systemBlue, for: .highlighted)
//        createButton.setTitleColor(.systemBlue, for: .selected)
//        createButton.layer.cornerRadius = 7
    }
}

// MARK: - Router

extension NewCompetitionStatusViewController: Router {}
