//
//  SettingsViewController.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 08/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SafariServices
import UIKit

class SettingsViewController: UIViewController, Nibbable {
    @IBOutlet var tableView: UITableView!

    var viewModel: SettingsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        setup()
    }

    func setup() {
        tableView.register(UINib(nibName: NormalTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: NormalTableViewCell.identifier)
        tableView.register(UINib(nibName: ToggleTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ToggleTableViewCell.identifier)
        tableView.register(UINib(nibName: ButtonTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ButtonTableViewCell.identifier)
        tableView.register(UINib(nibName: LinkTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: LinkTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SettingsViewController: UITableViewDelegate {
    private func clearAllUserDefaults() {
        UserDefaults.standard.dictionaryRepresentation().forEach { item in
            UserDefaults.standard.removeObject(forKey: item.key)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = viewModel.settings[indexPath.section].items[indexPath.row]
        switch data.type {
        case .profileAccount:
            presentProfileAccount()
            break
        case .notifications:
            presentNotificationSettings()
            break
        case .downloadData:
            presentDownloadData()
            break
        case .logout:
            displayWarningAlert(
                withTitle: "Log out",
                message: "Are you sure you want to Log out?") { [weak self] in
                    DispatchQueue.main.async {
                        self?.clearAllUserDefaults()
                        self?.presentSignIn()
                    }
                }
            break
        case .reportBug:
            presentReportBug()
            break
        case .suggestFeature:
            break
        case .aboutExhbt:
            presentSafareViewController(url: Links.exhbt)
            break
        case .termsOfService:
            presentSafareViewController(url: Links.terms)
            break
        case .privacyPolicy:
            presentSafareViewController(url: Links.privacy)
            break
        }
        debugLog(self, data.type.displayName())
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.settings[section].section
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.settings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settings[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = viewModel.settings[indexPath.section].items[indexPath.row]
        if data.type == .logout {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath) as? ButtonTableViewCell {
                cell.titleLabel.text = data.type.displayName()
                return cell
            }
        } else if data.type == .aboutExhbt || data.type == .termsOfService || data.type == .privacyPolicy {
            if let cell = tableView.dequeueReusableCell(withIdentifier: LinkTableViewCell.identifier, for: indexPath) as? LinkTableViewCell {
                cell.titleLabel.text = data.type.displayName()
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: NormalTableViewCell.identifier, for: indexPath) as? NormalTableViewCell {
                cell.titleLabel.text = data.type.displayName()
                cell.subtitleLabel.text = data.subtitle
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension SettingsViewController: Router {}
