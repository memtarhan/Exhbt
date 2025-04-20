//
//  NewEventViewController.swift
//  Exhbt
//
//  Created by Adem Tarhan on 27.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import MapKit
import PhotosUI
import UIKit

class NewEventViewController: BaseViewController, Nibbable {
    var viewModel: NewEventViewModel!

    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var libraryButtonView: UIView!
    @IBOutlet var selectedImageView: UIImageView!
    @IBOutlet var imageContentView: UIView!
    @IBOutlet var timeDurationSlider: UISlider!
    @IBOutlet var statusButton: ButtonWithMultipleImages!
    @IBOutlet var NSFWButton: UIButton!
    @IBOutlet var nsfwTickContainerView: UIView!
    @IBOutlet var createEventButton: UIButton!
    @IBOutlet var locationSearchBar: UISearchBar!

    private lazy var locationSearchResultsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        return tableView
    }()

    private var locationSearchResultsTableViewConstraints: [NSLayoutConstraint] {
        [locationSearchResultsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         locationSearchResultsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
         locationSearchResultsTableView.topAnchor.constraint(equalTo: locationSearchBar.bottomAnchor, constant: 8),
         locationSearchResultsTableView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5)]
    }

    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()

    // MARK: - Combine

    @Published var addedAsset = CurrentValueSubject<CCAsset?, Never>(nil)
    @Published var didAddTimeDuration = CurrentValueSubject<Bool, Never>(false)
    @Published var shouldEnableButton = PassthroughSubject<Bool, Never>()
    @Published var selectedEventType = CurrentValueSubject<EventType, Never>(.public)
    @Published var enabledButton = PassthroughSubject<Bool, Never>()

    @Published var didAddAsset = CurrentValueSubject<Bool, Never>(false)

    @Published var shouldDisplayLocations = CurrentValueSubject<Bool, Never>(false)
    @Published var shouldActivateSearchBar = CurrentValueSubject<Bool, Never>(false)

    private var cancellables: Set<AnyCancellable> = []

    private var shouldRequestPermission: Bool {
        PHPhotoLibrary.authorizationStatus() != .authorized
    }

    private var playerItem: AVPlayerItem?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    fileprivate let imageManager = PHCachingImageManager()

    var placeholder = "Write description here.."

    private let themeCornerRadius: CGFloat = 12.0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()
        viewModel.checkEligibility()
    }

    @IBAction func didTapAddPhoto(_ sender: Any) {
        ContentCreation.display(on: self, forContentType: .photoAndVideo) { _, asset, _ in
            if let asset {
                self.addedAsset.send(asset)
                self.didAddAsset.send(true)
            }
        }
    }

    @IBAction func didTapRemoveButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Remove this content?", message: nil, preferredStyle: .alert)
        let keepAction = UIAlertAction(title: "Keep the content", style: .cancel)
        alertController.addAction(keepAction)
        let cancelAction = UIAlertAction(title: "Remove the content", style: .destructive) { _ in
            self.didAddAsset.send(false)
            self.viewModel.eventCoverAsset = nil
        }
        alertController.addAction(cancelAction)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = [] // No arrow for the popover
        }
        present(alertController, animated: true)
    }

    @IBAction func didTapNSFWButton(_ sender: Any) {
        viewModel.eventIsNSFW = !viewModel.eventIsNSFW
        viewModel.eventIsNSFW ? NSFWButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal) : NSFWButton.setImage(nil, for: .normal)
    }

    @IBAction func didTapCreateButton(_ sender: Any) {
        startLoading()
        viewModel.create()
    }

    @IBAction func didChangeSlider(_ sender: UISlider) {
        if sender.value < 1.5 {
            sender.value = 1
            viewModel.eventDurationInDays = 1

        } else if sender.value > 2.5 {
            sender.value = 3
            viewModel.eventDurationInDays = 3

        } else {
            sender.value = 2
            viewModel.eventDurationInDays = 2
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

private extension NewEventViewController {
    func setupUI() {
        navigationItem.title = "Set Up Your Event"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        locationSearchBar.setImage(UIImage(systemName: "location.fill"), for: .search, state: .normal)
        searchCompleter.delegate = self
        locationSearchBar.delegate = self
        locationSearchResultsTableView.keyboardDismissMode = .onDrag
        locationSearchResultsTableView.delegate = self
        locationSearchResultsTableView.dataSource = self

        startLoading()

        scrollView.keyboardDismissMode = .onDrag

        descriptionTextView.layer.cornerRadius = themeCornerRadius
        libraryButtonView.layer.cornerRadius = themeCornerRadius
        selectedImageView.layer.cornerRadius = themeCornerRadius

        statusButton.delegate = self
        descriptionTextView.delegate = self

        nsfwTickContainerView.layer.borderWidth = 1.0
        nsfwTickContainerView.layer.borderColor = UIColor.systemBlue.cgColor
        nsfwTickContainerView.layer.cornerRadius = 4.0

        displayCoinsCountButton()
    }

    func setupSubscribers() {
        titleTextField.textPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.viewModel.eventTitle = text
            }
            .store(in: &cancellables)

        descriptionTextView.textPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.viewModel.eventDescription = text
            }
            .store(in: &cancellables)

        didAddAsset
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedPhoto in
                self?.libraryButtonView.isHidden = selectedPhoto
                self?.imageContentView.isHidden = !selectedPhoto
            }
            .store(in: &cancellables)

        addedAsset
            .receive(on: RunLoop.main)
            .sink { [weak self] asset in
                guard let self = self,
                      let asset = asset else { return }
                self.didAddAsset.send(true)
                self.viewModel.eventCoverAsset = asset

                if let image = asset.image {
                    self.selectedImageView.image = image

                } else if let videoURL = asset.videoURL {
                    self.player = AVPlayer(url: videoURL)
                    self.playerLayer = AVPlayerLayer(player: self.player)

                    // add player layer to view layer
                    self.playerLayer?.frame = self.imageContentView.bounds
                    self.playerLayer?.videoGravity = .resizeAspectFill
                    self.playerLayer?.cornerRadius = self.themeCornerRadius

                    if let playerLayer = self.playerLayer {
                        self.imageContentView.layer.addSublayer(playerLayer)
                    }

                    self.player?.play()

                    // handle video end
                    NotificationCenter.default.addObserver(self, selector: #selector(self.videoEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                }
            }
            .store(in: &cancellables)

        shouldDisplayLocations
            .receive(on: DispatchQueue.main)
            .sink { display in
                display ? self.view.addSubview(self.locationSearchResultsTableView) : self.locationSearchResultsTableView.removeFromSuperview()
                display ? NSLayoutConstraint.activate(self.locationSearchResultsTableViewConstraints) : NSLayoutConstraint.deactivate(self.locationSearchResultsTableViewConstraints)
            }
            .store(in: &cancellables)

        shouldActivateSearchBar
            .receive(on: DispatchQueue.main)
            .sink { activated in
                self.locationSearchBar.showsCancelButton = activated
                if activated { _ = self.locationSearchBar.becomeFirstResponder() }
                else { _ = self.locationSearchBar.resignFirstResponder() }
            }
            .store(in: &cancellables)

        selectedEventType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                self?.viewModel.eventType = type
                self?.statusButton.title = type.title
                self?.statusButton.leftImage = type.image
            }
            .store(in: &cancellables)

        viewModel.dismissPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)

        viewModel.eligiblePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] eligible in
                self?.stopLoading()
                if !eligible {
                    self?.displayIneligibilityAlert(message: "You do not have enough coins to create an Event but you can earn coins with Flash game", completion: {
                        self?.dismiss(animated: true)
                        UserSettings.shared.shouldShowFlashAtLaunch = true
                        AppState.shared.shouldShowFlash.send()
                    })
                }
            }
            .store(in: &cancellables)

        viewModel.enablePublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: createEventButton)
            .store(in: &cancellables)
    }
}

extension NewEventViewController: Router {}

// MARK: - ButtonWithMultipleImagesDelegate

extension NewEventViewController: ButtonWithMultipleImagesDelegate {
    func buttonWithMultipleImagesDidTap() {
        let actions = EventType.allCases.map { type in
            AlertAction(title: type.title, image: type.image, style: .default) { _ in
                self.selectedEventType.send(type)
            }
        }
        presentActionSheet(withTitle: "Who can join the competition", message: nil, actions: actions)
    }
}

// MARK: - LocationsDelegate

extension NewEventViewController: LocationsDelegate {
    func locations(didSelectAddress address: AddressModel) {
        debugLog(self, address)
        viewModel.eventAddress = address
    }
}

// MARK: - UITextViewDelegate

extension NewEventViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor == .lightGray {
            descriptionTextView.text = nil
            descriptionTextView.textColor = .black
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            descriptionTextView.resignFirstResponder()
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = placeholder
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
}

// MARK: - UISearchBarDelegate

extension NewEventViewController: UISearchBarDelegate {
    // This method declares that whenever the text in the searchbar is change to also update
    // the query that the searchCompleter will search based off of
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        shouldActivateSearchBar.send(true)
        searchCompleter.queryFragment = searchText
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldActivateSearchBar.send(false)
        locationSearchBar.text = nil
        locationSearchBar.resignFirstResponder()

        shouldDisplayLocations.send(false)
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension NewEventViewController: MKLocalSearchCompleterDelegate {
    // This method declares gets called whenever the searchCompleter has new search results
    // If you wanted to do any filter of the locations that are displayed on the the table view
    // this would be the place to do it.
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Setting our searcResults variable to the results that the searchCompleter returned
        searchResults = completer.results

        // Reload the tableview with our new searchResults
        locationSearchResultsTableView.reloadData()

        shouldDisplayLocations.send(true)
    }

    // This method is called when there was an error with the searchCompleter
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Error
    }
}

// MARK: - UITableViewDataSource

extension NewEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle

        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)

        let result = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)

        let search = MKLocalSearch(request: searchRequest)
        search.start { response, _ in
            guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                return
            }

            guard let name = response?.mapItems[0].placemark.title else {
                return
            }

            let latitude = coordinate.latitude
            let longitude = coordinate.longitude

            let address = AddressModel(fullAddress: name, latitude: latitude, longitude: longitude)
            self.viewModel.eventAddress = address
            self.locationSearchBar.text = name
            self.shouldDisplayLocations.send(false)
            self.shouldActivateSearchBar.send(false)
        }
    }
}
