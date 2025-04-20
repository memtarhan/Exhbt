//
//  NewCompetitionViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/08/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

protocol NewCompetitionDelegate: AnyObject {
    func newCompetitionDidFinishWithInvitation()
    func newCompetitionDidFinish()
}

class NewCompetitionViewController: BaseViewController, Nibbable {
    var viewModel: NewCompetitionViewModel!

    var exhbtId: Int? {
        didSet {
            viewModel.exhbtId = exhbtId
        }
    }

    var type: NewCompetitionType = .new
    weak var delegate: NewCompetitionDelegate?

    @IBOutlet var photoView: UIView!
    @IBOutlet var photoIndicatorImageView: UIImageView!
    @IBOutlet var addPhotoButtonContentView: UIView!
    @IBOutlet var addPhotoButtonContainerView: UIView!
    @IBOutlet var selectedPhotoContainerView: UIView!
    @IBOutlet var selectedPhotoImageView: UIImageView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var coinIndicationView: UIView!

    @Published var didAddAsset = CurrentValueSubject<Bool, Never>(false)
    @Published var addedAsset = CurrentValueSubject<CCAsset?, Never>(nil)
    @Published var addedImage = CurrentValueSubject<UIImage?, Never>(nil)
    @Published var shouldEnableButton = PassthroughSubject<Bool, Never>()

    private var cancellables: Set<AnyCancellable> = []

    private var eligible = false

    private let themeCornerRadius: CGFloat = 12.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewModel.checkEligibility()
    }

    @IBAction func didTapRemovePhoto(_ sender: Any) {
        didAddAsset.send(false)
    }

    @IBAction func didTapAddPhoto(_ sender: Any) {
        ContentCreation.display(on: self) { _, asset, _ in
            if let asset {
                self.addedAsset.send(asset)
                self.didAddAsset.send(true)
            }
        }
    }

    @IBAction func didTapCreate(_ sender: UIButton) {
        sender.isEnabled = false
        startLoading()

        let asset = addedAsset.value
        let image = addedImage.value

        viewModel.create(withAsset: asset, image: image, type: type)
    }

    private func setup() {
        navigationItem.title = type.title
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        addButton.setTitle(type.buttonTitle, for: .normal)

        photoView.isHidden = false
        selectedPhotoContainerView.isHidden = true

        buttonView.isHidden = false

        addPhotoButtonContainerView.layer.cornerRadius = themeCornerRadius
        selectedPhotoImageView.layer.cornerRadius = themeCornerRadius

        coinIndicationView.layer.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor
        coinIndicationView.layer.cornerRadius = 12

        startLoading()

        didAddAsset
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedPhoto in
                guard let self = self else { return }
                self.shouldEnableButton.send(selectedPhoto && self.eligible)
                self.photoIndicatorImageView.image = selectedPhoto ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "1.circle")
                self.photoIndicatorImageView.tintColor = selectedPhoto ? UIColor.systemGreen : UIColor.black
                self.addPhotoButtonContentView.isHidden = selectedPhoto
                self.selectedPhotoContainerView.isHidden = !selectedPhoto
            }
            .store(in: &cancellables)

        addedAsset
            .receive(on: DispatchQueue.main)
            .sink { [weak self] asset in
                guard let self = self,
                      let asset = asset else { return }
                self.didAddAsset.send(true)
                if let image = asset.image {
                    self.selectedPhotoImageView.image = image
                }
            }
            .store(in: &cancellables)

        addedImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self,
                      let image = image else { return }
                self.didAddAsset.send(true)
                self.selectedPhotoImageView.image = image
            }
            .store(in: &cancellables)

        shouldEnableButton
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: addButton)
            .store(in: &cancellables)

        viewModel.willDismiss
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.dismissView()

                case .failure:
                    self?.stopLoading(withResult: .failure(.getType()))
                }
            } receiveValue: { _ in
            }

            .store(in: &cancellables)

        viewModel.eligiblePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] eligible in
                self?.eligible = eligible
                self?.stopLoading()
                if !eligible {
                    self?.displayIneligibilityAlert(message: "You do not have enough coins to join this Exhbt but you can earn coins with Flash game", completion: {
                        self?.dismiss(animated: true)
                        UserSettings.shared.shouldShowFlashAtLaunch = true
                        AppState.shared.shouldShowFlash.send()
                    })

                } else {
                    self?.displayCoinsCountButton()
                }
            }
            .store(in: &cancellables)
    }

    private func dismissView() {
        if type == .joinWithInvitation {
            delegate?.newCompetitionDidFinishWithInvitation()

        } else if type == .join {
            delegate?.newCompetitionDidFinish()
        }

        navigationController?.dismiss(animated: true)
    }
}

// MARK: - Navigations

extension NewCompetitionViewController: Router {}
