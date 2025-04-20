//
//  NotificationSettingsViewController.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 09/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: UIViewController, Nibbable {

    @IBOutlet var tableView: UITableView!
    
    var viewModel: NotificationSettingsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        setup()
    }
    
    func setup() {
        tableView.register(UINib(nibName: ToggleTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ToggleTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension NotificationSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = viewModel.notificationSettings[indexPath.section].items[indexPath.row]
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

extension NotificationSettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.notificationSettings[section].section
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.notificationSettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notificationSettings[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = viewModel.notificationSettings[indexPath.section].items[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier, for: indexPath) as? ToggleTableViewCell {
            cell.titleLabel.text = data.type.displayName()
            cell.toggle.isOn = data.toggle ?? false
            cell.delegate = self
            cell.separarorLine.alpha = (viewModel.notificationSettings[indexPath.section].items.count - 1) == indexPath.row ? 0 : 1
            return cell
        }
        return UITableViewCell()
    }
}

extension NotificationSettingsViewController: ToggleTableViewCellDelegate {
    
    func didTapToggleTableViewCell(_ cell: ToggleTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.notificationSettings[indexPath.section].items[indexPath.row].toggle = cell.toggle.isOn
    }
}
