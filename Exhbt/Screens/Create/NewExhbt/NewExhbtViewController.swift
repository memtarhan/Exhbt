//
//  NewExhbtViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import AVFoundation
import Combine
import UIKit

protocol NewExhbtDelegate: AnyObject {
    func newExhbtWillDismiss(_ exhbtId: Int, exhbtType type: ExhbtType)
    func newExhbtWillShowChooseCompetitors(_ exhbtId: Int)
}

class NewExhbtViewController: BaseViewController, Nibbable {
    var viewModel: NewExhbtViewModel!

    @IBOutlet var scrollView: UIScrollView!

    // MARK: - Photo

    @IBOutlet var assetContainerView: UIView!
    @IBOutlet var photoView: UIView!
    @IBOutlet var photoIndicatorImageView: UIImageView!
    @IBOutlet var addPhotoButtonContentView: UIView!
    @IBOutlet var addPhotoButtonContainerView: UIView!
    @IBOutlet var selectedPhotoContainerView: UIView!
    @IBOutlet var selectedPhotoImageView: UIImageView!

    @IBOutlet var statusButton: ButtonWithMultipleImages!

    @IBOutlet var coinIndicationView: UIView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var createButton: UIButton!

    @Published var didAddAsset = CurrentValueSubject<Bool, Never>(false)
    @Published var addedAsset = CurrentValueSubject<CCAsset?, Never>(nil)
    @Published var selectedExhbtType = CurrentValueSubject<ExhbtType, Never>(.public)
    @Published var shouldEnableButton = PassthroughSubject<Bool, Never>()

    private var cancellables: Set<AnyCancellable> = []

    private var eligible = false

    private let themeCornerRadius: CGFloat = 12.0

    private var playerItem: AVPlayerItem?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    var playerObserver: NSKeyValueObservation!

    weak var delegate: NewExhbtDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewModel.checkEligibility()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        player?.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        player?.pause()
    }

    @IBAction func didTapRemovePhoto(_ sender: Any) {
        let alertController = UIAlertController(title: "Remove this content?", message: nil, preferredStyle: .alert)
        let keepAction = UIAlertAction(title: "Keep the content", style: .cancel)
        alertController.addAction(keepAction)
        let cancelAction = UIAlertAction(title: "Remove the content", style: .destructive) { _ in
            self.cleanup()
        }
        alertController.addAction(cancelAction)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = [] // No arrow for the popover
        }
        present(alertController, animated: true)
    }

    @IBAction func didTapAddPhoto(_ sender: Any) {
        ContentCreation.display(on: self) { _, asset, _ in
            if let asset {
                self.addedAsset.send(asset)
                self.didAddAsset.send(true)
            }
        }
    }

    @IBAction func didTapNext(_ sender: UIButton) {
        guard let asset = addedAsset.value else { return }
        let exhbtType = selectedExhbtType.value

        presentNewExhbtSetup(withAsset: asset, exhbtType: exhbtType, delegate: delegate)
    }

    private func setup() {
        navigationItem.title = "Set Up Your Exhbt"
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        startLoading()

        scrollView.keyboardDismissMode = .onDrag

        photoView.isHidden = false
        selectedPhotoContainerView.isHidden = true

        buttonView.isHidden = false

        addPhotoButtonContainerView.layer.cornerRadius = themeCornerRadius
        selectedPhotoImageView.layer.cornerRadius = themeCornerRadius

        statusButton.delegate = self

        coinIndicationView.layer.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor
        coinIndicationView.layer.cornerRadius = 12

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

                } else if let videoURL = asset.videoURL {
                    self.player = AVPlayer(url: videoURL)
                    self.playerLayer = AVPlayerLayer(player: self.player)

                    // add player layer to view layer
                    self.playerLayer?.frame = self.assetContainerView.bounds
                    self.playerLayer?.videoGravity = .resizeAspectFill
                    self.playerLayer?.cornerRadius = self.themeCornerRadius

                    if let playerLayer = self.playerLayer {
                        self.assetContainerView.layer.addSublayer(playerLayer)
                    }

                    self.player?.play()

                    // handle video end
                    NotificationCenter.default.addObserver(self, selector: #selector(self.videoEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                }
            }
            .store(in: &cancellables)

        selectedExhbtType
            .receive(on: DispatchQueue.main)
            .sink { type in
                self.statusButton.title = type.title
                self.statusButton.leftImage = type.image
            }
            .store(in: &cancellables)

        shouldEnableButton
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: createButton)
            .store(in: &cancellables)

        viewModel.eligiblePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] eligible in
                self?.eligible = eligible
                self?.stopLoading()
                if !eligible {
                    self?.displayIneligibilityAlert(message: "You do not have enough coins to create an Exhbt but you can earn coins with Flash game", completion: {
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

    private func cleanup() {
        didAddAsset.send(false)
        shouldEnableButton.send(false)
        stopLoading()

        player?.pause()
        player = nil

        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }

    // Observes when the player item is ready to play and handles automatic play back
    private func observePlayer(_ playerItem: AVPlayerItem) {
        playerObserver = playerItem.observe(\AVPlayerItem.status) { [weak self] playerItem, _ in
            if playerItem.status == .readyToPlay {
                self?.player?.play()
            }
        }
    }

    @objc private func videoEnded() {
        playerItem?.seek(to: CMTime.zero) { finished in
            if finished {
                OperationQueue.main.addOperation { [weak self] in
                    self?.player?.play()
                }
            }
        }
    }
}

// MARK: - Navigations

extension NewExhbtViewController: Router {}

// MARK: - ButtonWithMultipleImagesDelegate

extension NewExhbtViewController: ButtonWithMultipleImagesDelegate {
    func buttonWithMultipleImagesDidTap() {
        debugLog(self, #function)
        let actions = ExhbtType.allCases.map { type in
            AlertAction(title: type.title, image: type.image, style: .default, handler: { _ in
                self.selectedExhbtType.send(type)
            })
        }

        presentActionSheet(withTitle: "Who can join the competition",
                           message: nil, actions: actions)
    }
}

// MARK: - ChooseCompetitorsDelegate

extension NewExhbtViewController: ChooseCompetitorsDelegate {
    func chooseCompetitorsWillDismiss() {
        DispatchQueue.main.async {
            self.stopLoading()
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
