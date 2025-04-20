//
//  EventDetailsViewController.swift
//  Exhbt
//
//  Created by Adem Tarhan on 1.10.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Contacts
import UIKit

class XEventDetailsViewController: BaseViewController, Nibbable {
    var viewModel: EventDetailsViewModel!

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var postButton: UIButton!

    var event: EventDisplayModel?

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

    @IBAction func didTapJoinEvent(_ sender: Any) {
        guard let event else { return }

        if event.joined {
            viewModel.checkEligibilityForPosting()

        } else {
            // Join
            viewModel.join(eventId: event.id)
        }
    }

    @objc
    private func didTapInvite() {
        debugLog(self, #function)
        let permission = CNContactStore.authorizationStatus(for: .contacts)
        if permission == .notDetermined {
            presentNewCompetitionStatus(withType: .contacts, fromSource: self)
        } else if permission == .authorized {
            guard let event else { return }
            presentInvite(eventId: event.id)
        } else {
            stopLoading(withResult: .failure(.getType()))
        }
    }
}

private extension XEventDetailsViewController {
    func setupUI() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 24, weight: .black),
        ]

        view.backgroundColor = .competitionBackgroundColor
        tabBarController?.tabBar.isHidden = true
        collectionView.backgroundColor = .competitionBackgroundColor

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false

        collectionView.contentInsetAdjustmentBehavior = .never

        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.collectionViewLayout = createComponsitionalLayout()

        collectionView.register(UINib(nibName: XEventDetailsCollectionViewCell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: XEventDetailsCollectionViewCell.reuseIdentifier)

        guard let event else {
            return dismiss(animated: true)
        }

        if event.isOwn {
            let inviteButton = UIBarButtonItem(image: UIImage(named: "Button-Invite"), style: .plain, target: self, action: #selector(didTapInvite))
            navigationItem.rightBarButtonItem = inviteButton
            postButton.isHidden = true

        } else {
            let buttonImage = event.joined ? UIImage(named: "Button-PostEvent") : UIImage(named: "Button-JoinEvent")
            postButton.setImage(buttonImage, for: .normal)
        }
    }

    func setupSubscribers() {
        viewModel.joinedPublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure:
                    // TODO: Present alert
                    break
                case .finished:
                    break
                }
            } receiveValue: { _ in
                self.event?.joined = true
                let buttonImage = UIImage(named: "Button-PostEvent")
                self.postButton.setImage(buttonImage, for: .normal)
            }
            .store(in: &cancellables)

        viewModel.eligibleToJoinPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] eligible in
                if !eligible {
                    // TODO: Add navigation to Flash
                    self?.displayAlert(withTitle: "Oops, not enough coins to join", message: "You do not have enough coins to join this Event") {
                        self?.dismiss(animated: true)
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.eligibleToPostPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] eligible in
                if !eligible {
                    // TODO: Add navigation to Flash
                    self?.displayAlert(withTitle: "Oops, not enough coins to post", message: "You do not have enough coins to post in this Event") {
                        self?.dismiss(animated: true)
                    }

                } else {
                    guard let event = self?.event else { return }
                    self?.presentNewPost(event: event)
                }
            }
            .store(in: &cancellables)
    }
}

private extension XEventDetailsViewController {
    func createComponsitionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            self.createSection()
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        config.contentInsetsReference = .none
        config.interSectionSpacing = 0
        layout.configuration = config

        return layout
    }

    func createSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.4))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging

        return section
    }
}

extension XEventDetailsViewController: UICollectionViewDelegate {}

extension XEventDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        event?.posts.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: XEventDetailsCollectionViewCell.reuseIdentifier, for: indexPath) as! XEventDetailsCollectionViewCell

        if let post = event?.posts[indexPath.row] {
            cell.configure(post)
        }

        return cell
    }
}

extension XEventDetailsViewController: Router {}
