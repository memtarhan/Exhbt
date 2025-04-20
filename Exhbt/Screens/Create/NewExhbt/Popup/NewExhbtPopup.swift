//
//  NewExhbtPopup.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 25/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SPConfetti
import UIKit

class NewExhbtPopup: UIViewController, Nibbable {
    private lazy var gradient: CAGradientLayer = {
        GradientLayers.exhbtStatusWhiteCover
    }()

    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var spinnerView: Spinner!
    @IBOutlet var expandButton: UIButton!
    @IBOutlet var nextDetailsStackView: UIStackView!
    @IBOutlet var lineView: UIView!
    @IBOutlet var expandableView: UIStackView!
    @IBOutlet var coinIndicationView: UIView!

    var exhbtId: Int?
    var exhbtType: ExhbtType = .public

    private var cancellables: Set<AnyCancellable> = []

    @Published var shouldExpand = CurrentValueSubject<Bool, Never>(false)

    weak var delegate: NewExhbtDelegate?

    private var timer: Timer?

    private var time: TimeInterval = TimeInterval((UserSettings.shared.exhbtSubmissionDuration) * 60 * 60)

    override func viewDidLoad() {
        super.viewDidLoad()

        guard exhbtId != nil else {
            dismiss(animated: true)
            return
        }
        spinnerView.startRefreshing()

        gradient.frame = expandableView.bounds
        expandableView.layer.addSublayer(gradient)

        let text = "It’s \(exhbtType.emoji) \(exhbtType.title): \n\(exhbtType.info)"
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)

        let length = exhbtType == .public ? 22 : 23
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: NSRange(location: 8, length: length))
        subtitleLabel.attributedText = attributedString

        coinIndicationView.layer.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor
        coinIndicationView.layer.cornerRadius = 12

        startTimer()

        shouldExpand
            .receive(on: DispatchQueue.main)
            .sink { expanded in
                self.lineView.isHidden = !expanded
                let buttonImage = expanded ? UIImage(named: "Exhbt-chevron-top") : UIImage(named: "Exhbt-chevron-bottom")
                self.expandButton.setImage(buttonImage, for: .normal)
                self.nextDetailsStackView.isHidden = !expanded
                if let sheet = self.sheetPresentationController {
                    sheet.animateChanges {
                        sheet.detents = expanded ? [.large()] : [.medium()]
                    }
                }
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SPConfetti.startAnimating(.centerWidthToDown, particles: [.triangle, .arc], duration: 3)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        timer?.invalidate()
        timer = nil
    }

    @IBAction func didTapExpand(_ sender: Any) {
        shouldExpand.send(!shouldExpand.value)
    }

    @IBAction func didTapInviteCompetitors(_ sender: Any) {
        guard let exhbtId else { return }
        dismiss(animated: true) {
            self.delegate?.newExhbtWillShowChooseCompetitors(exhbtId)
        }
    }

    @IBAction func didTapGotIt(_ sender: Any) {
        dismiss(animated: true)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.time -= 1
            self?.updateTimerLabel()
            if self?.time == 0 { self?.timer?.invalidate() }
        })
    }

    private func updateTimerLabel() {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]

        let formattedDuration = formatter.string(from: time)

        timerLabel.text = "Pending Competitors • \(formattedDuration!)"
    }
}

// MARK: - Router

extension NewExhbtPopup: Router { }

// MARK: - ChooseCompetitorsDelegate

extension NewExhbtPopup: ChooseCompetitorsDelegate {
    func chooseCompetitorsWillDismiss() {
        debugLog(self, #function)
    }
}
