//
//  ContentCreationViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/10/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Photos
import SwiftUI
import UIKit
import YPImagePicker

enum CCAssetType: String {
    case image
    case video
}

struct CCAsset {
    let type: CCAssetType
    let image: UIImage?
    let videoURL: URL?
    let thumbnail: UIImage?
    let aspectRatio: Double
}

class ContentCreation: UIViewController {
    var completion: ((_ contentCreation: ContentCreation?, _ asset: CCAsset?, _ cancelled: Bool) -> Void)?
    var configuration: YPImagePickerConfiguration?

    // MARK: - Views

    private var permissionsSubview: (UIView & UIContentView)?
    private var previewSubview: (UIView & UIContentView)?
    private var pickerSubview: (UIView & UIContentView)?

    private var hasPhotoLibraryPermission: Bool {
        (PHPhotoLibrary.authorizationStatus() == .authorized) ||
            (PHPhotoLibrary.authorizationStatus() == .limited)
    }

    @Published var shouldDisplayPermissions = PassthroughSubject<Bool, Never>()
    @Published var shouldDisplayPreview = PassthroughSubject<Bool, Never>()
    @Published var shouldDisplayPicker = PassthroughSubject<Bool, Never>()
    @Published var shouldDismiss = PassthroughSubject<Void, Never>()

    private var cancellables: Set<AnyCancellable> = []

    private var selectedAsset: CCAsset? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()

        shouldDisplayPermissions.send(!hasPhotoLibraryPermission)
        shouldDisplayPicker.send(hasPhotoLibraryPermission)
    }

    /// - Parameters:
    ///   - on: View controller as a source to display Content Creation
    ///   - forContentType: Content type be displayed. default is .photo
    ///   - completion: A completion handler with instance of Content Creation, an asset and cancelled indicator value
    static func display(on source: UIViewController, forContentType contentType: DisplayableContentType = .photo, completion: @escaping (_ contentCreation: ContentCreation?, _ asset: CCAsset?, _ cancelled: Bool) -> Void) {
        let instance: ContentCreation = ContentCreation()
        instance.configuration = ContentCreationConfiguration.getPickerConfiguration(forContentType: contentType)
        instance.completion = completion
        source.present(instance, animated: true)
    }

    // MARK: - Actions

    private func cancel() {
        shouldDismiss.send()
        completion?(self, nil, true)
    }

    private func finish() {
        shouldDismiss.send()
        completion?(self, selectedAsset, false)
    }

    private func requestPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .notDetermined, .restricted, .denied:
                if self?.permissionsSubview == nil {
                    self?.shouldDisplayPermissions.send(true)
                }

                self?.displayPermissionsAlert()

            case .authorized, .limited:
                self?.shouldDisplayPermissions.send(false)
                self?.shouldDisplayPicker.send(true)

            @unknown default:
                break
            }
        }
    }
}

// MARK: - Setup

private extension ContentCreation {
    func setupUI() {
        view.backgroundColor = .systemBackground
    }

    func setupSubscribers() {
        shouldDisplayPermissions
            .receive(on: RunLoop.main)
            .sink { [weak self] display in
                display ? self?.displayPermissions() : self?.dismissPermissions()
            }
            .store(in: &cancellables)

        shouldDisplayPreview
            .receive(on: RunLoop.main)
            .sink { [weak self] display in
                display ? self?.displayPreview() : self?.dismissPreview()
            }
            .store(in: &cancellables)

        shouldDisplayPicker
            .receive(on: RunLoop.main)
            .sink { [weak self] display in
                if display { self?.displayPicker() }
            }
            .store(in: &cancellables)

        shouldDismiss
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Display

private extension ContentCreation {
    func displayPermissions() {
        let permissionsView = ContentPermissionsView { [weak self] _ in
            self?.requestPermission()
        }

        let config = UIHostingConfiguration {
            permissionsView
        }
        permissionsSubview = config.makeContentView()

        guard let permissionsSubview else { return }

        permissionsSubview.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(permissionsSubview)

        NSLayoutConstraint.activate([
            permissionsSubview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            permissionsSubview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            permissionsSubview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            permissionsSubview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    func dismissPermissions() {
        guard let permissionsSubview else { return }

        NSLayoutConstraint.deactivate([
            permissionsSubview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            permissionsSubview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            permissionsSubview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            permissionsSubview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        permissionsSubview.removeFromSuperview()

        self.permissionsSubview = nil
    }

    func displayPreview() {
        guard let selectedAsset else { return }
        let contentPreview = ContentPreview(asset: selectedAsset) { [weak self] cancelled in
            cancelled ? self?.cancel() : self?.finish()
        }

        let config = UIHostingConfiguration {
            contentPreview
        }
        pickerSubview = config.makeContentView()

        guard let pickerSubview else { return }

        pickerSubview.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(pickerSubview)

        NSLayoutConstraint.activate([
            pickerSubview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pickerSubview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pickerSubview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pickerSubview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    func dismissPreview() {
        guard let pickerSubview else { return }

        NSLayoutConstraint.deactivate([
            pickerSubview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pickerSubview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pickerSubview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pickerSubview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        pickerSubview.removeFromSuperview()

        self.pickerSubview = nil
    }

    func displayPicker() {
        guard let configuration else { return }
        let picker = YPImagePicker(configuration: configuration)
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                self.cancel()
            }

            
            if let photo = items.singlePhoto {
                let width = photo.image.size.width
                let height = photo.image.size.height
                let aspectRatio: Double = height / width
                
                self.selectedAsset = CCAsset(type: .image, image: photo.image, videoURL: nil, thumbnail: nil, aspectRatio: aspectRatio)

            } else if let video = items.singleVideo {
                let width = video.asset?.pixelWidth ?? 1
                let height = video.asset?.pixelHeight ?? 1
                let aspectRatio: Double = Double(height) / Double(width)
                
                self.selectedAsset = CCAsset(type: .video, image: nil, videoURL: video.url, thumbnail: video.thumbnail, aspectRatio: aspectRatio)


            } else {
                self.cancel()
            }

            picker.willMove(toParent: nil)
            picker.view.removeFromSuperview()
            picker.removeFromParent()

            self.shouldDisplayPreview.send(true)
        }

        let pickerView = picker.view!
        pickerView.translatesAutoresizingMaskIntoConstraints = false

        addChild(picker)
        view.addSubview(pickerView)

        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pickerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        picker.didMove(toParent: self)
    }

    func displayPermissionsAlert() {
        let alert = UIAlertController(
            title: "Please Allow Access to your Photos",
            message: "This Allows Exhbt to share photos from your library.",
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { success in
                    debugLog(self, "Settings opened: \(success)")
                })
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(openSettingsAction)
        DispatchQueue.main.async {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = [] // No arrow for the popover
            }
            self.present(alert, animated: true)
        }
    }
}

enum DisplayableContentType: String {
    case photo
    case video
    case photoAndVideo

    var asYPlibraryMediaType: YPlibraryMediaType {
        switch self {
        case .photo:
            return .photo
        case .video:
            return .video
        case .photoAndVideo:
            return .photoAndVideo
        }
    }
}

// MARK: - Picker Configuration

enum ContentCreationConfiguration {
    static func getPickerConfiguration(forContentType type: DisplayableContentType) -> YPImagePickerConfiguration {
        var config = YPImagePickerConfiguration()

        /// - General
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.usesFrontCamera = false
        config.showsPhotoFilters = true
        config.showsVideoTrimmer = true
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "DefaultYPImagePickerAlbumName"
        config.startOnScreen = YPPickerScreen.photo
        config.screens = [.library, .photo, .video]
        config.showsCrop = .none
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = true
        config.hidesBottomBar = false
        config.hidesCancelButton = false
        config.preferredStatusBarStyle = UIStatusBarStyle.default
        config.bottomMenuItemSelectedTextColour = .red
        config.bottomMenuItemUnSelectedTextColour = .purple
//        config.filters = [DefaultYPFilters...]
        config.maxCameraZoomFactor = 1.0
//        config.fonts..
        config.colors.tintColor = .systemBlue

        /// - Library
        config.library.options = nil
        config.library.onlySquare = false
        config.library.isSquareByDefault = true
        config.library.minWidthForItem = nil
        config.library.mediaType = type.asYPlibraryMediaType
        config.library.defaultMultipleSelection = false
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = false
        config.library.preselectedItems = nil
        config.library.preSelectItemOnMultipleSelection = true

        /// - Video
        config.video.compression = AVAssetExportPresetHighestQuality
        config.video.fileType = .mp4
        config.video.recordingTimeLimit = 15.0
//        config.video.libraryTimeLimit = 15.0
        config.video.minimumTimeLimit = 5.0
        config.video.trimmerMaxDuration = 15.0
        config.video.trimmerMinDuration = 3.0

        /// - Gallery
        config.gallery.hidesRemoveButton = false

        return config
    }
}
