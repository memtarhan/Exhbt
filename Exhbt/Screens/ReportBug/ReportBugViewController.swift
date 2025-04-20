//
//  ReportBugViewController.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 09/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Photos
import UIKit

class ReportBugViewController: UIViewController, Nibbable {
    var viewModel: ReportBugViewModel!

    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var defineIssueLabel: UILabel!
    @IBOutlet var defineIssueTextField: UITextField!
    @IBOutlet var defineIssueTextView: UITextView!
    @IBOutlet var defineIssueTextViewHeigtConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var sendReportButton: UIButton!
    @IBOutlet var addScreenshotsButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewheightConstraint: NSLayoutConstraint!

    lazy var dataSource = generatedDataSource
    var cancellables: Set<AnyCancellable> = []
    let rowHeight: CGFloat = 76

    override func viewDidLoad() {
        super.viewDidLoad()
        defineIssueTextView.delegate = self
        title = "Report a Bug"
        setup()
        checkEnableButton()
    }

    func setup() {
        let cell = UINib(nibName: ReportBugCell.identifier, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: ReportBugCell.identifier)
        tableView.dataSource = dataSource
        tableView.rowHeight = rowHeight
        viewModel.snapshot
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] snapshot in
                guard let self = self else { return }
                self.dataSource.apply(snapshot, animatingDifferences: false)
                self.tableViewheightConstraint.constant = CGFloat(snapshot.numberOfItems) * self.rowHeight
            }
            .store(in: &cancellables)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addScreenshotsButton.layer.borderColor = UIColor.systemBlue.cgColor
        addScreenshotsButton.layer.borderWidth = 1
        addScreenshotsButton.layer.cornerRadius = 10
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisAppear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private var generatedDataSource: ReportBugTableViewDiffableDataSource {
        ReportBugTableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, model -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportBugCell.identifier, for: indexPath) as? ReportBugCell
            else { return UITableViewCell() }
            cell.configure(model, on: self)
            return cell
        }
    }

    @objc
    func keyboardWillAppear(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight: CGFloat
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0.0
        keyboardHeight = keyboardFrame.cgRectValue.height - tabBarHeight
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }

    @objc
    func keyboardWillDisAppear(notification: NSNotification?) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 16
            self.view.layoutIfNeeded()
        }
    }

    private func checkEnableButton() {
        emailTextField.text = "no email address found" // UserSettings.shared.email
        let showEmailLabel = emailTextField.text?.count ?? 0 > 0
        let showTitleLabel = titleTextField.text?.count ?? 0 > 0
        let showDefineYourIssueLabel = defineIssueTextView.text.count > 0
        let isValidEmail = emailTextField.text?.isValidEmail ?? false
        emailLabel.alpha = showEmailLabel ? 1 : 0
        titleLabel.alpha = showTitleLabel ? 1 : 0
        defineIssueLabel.alpha = showDefineYourIssueLabel ? 1 : 0
        defineIssueTextField.alpha = showDefineYourIssueLabel ? 0 : 1
        defineIssueTextViewHeigtConstraint.constant = defineIssueTextView.contentSize.height
        if isValidEmail {
            sendReportButton.backgroundColor = .systemBlue
            sendReportButton.isEnabled = true
        } else {
            sendReportButton.backgroundColor = .systemGray4
            sendReportButton.isEnabled = false
        }
    }

    @IBAction func didTapSendReport() {
    }

    @IBAction func emailFieldEditingChanged(_ sender: Any) {
        checkEnableButton()
    }

    @IBAction func titleFieldEditingChanged(_ sender: Any) {
        checkEnableButton()
    }

    @IBAction func didTapAddScreenshot() {
        // TODO: - Present content creation
    }

    func didTapConfirm(asset: PHAsset?, image: UIImage?) {
        // TODO: Retrieve asset
//        viewModel.addedAsset.send(asset)
//        viewModel.addedImage.send(image)
    }
}

extension ReportBugViewController: ReportBugCellDelegate {
    func didTapTrash(cell: ReportBugCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let sectionIdentifier = viewModel.snapshot.value.sectionIdentifiers[indexPath.section]
            let itemIdentifiers = viewModel.snapshot.value.itemIdentifiers(inSection: sectionIdentifier)
            if indexPath.row < itemIdentifiers.count {
                let itemToRemove = itemIdentifiers[indexPath.row]
                viewModel.snapshot.value.deleteItems([itemToRemove])
            }
        }
    }
}

extension ReportBugViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkEnableButton()
    }
}

extension ReportBugViewController: Router {}
