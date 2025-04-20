//
//  CompetitionsInfoPopup.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 16/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

class CompetitionsInfoPopup: UIViewController, Nibbable {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var itemsStackView: UIStackView!

    private let points = ["Anyone can view your contest",
                          "Anyone can vote on your contest",
                          "You can see who is participating in the contest",
                          "Photos are anonymous",
                          "See full Competition Rules"]

    override func viewDidLoad() {
        super.viewDidLoad()

        bulletPointList(strings: points)
    }

    @IBAction func didTapBack(_ sender: Any) {
        dismiss(animated: true)
    }

    @objc func didTapCompetitionRules(_ sender: Any) {
        debugLog(self, #function)
    }

    func bulletPointList(strings: [String]) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 15
        paragraphStyle.minimumLineHeight = 22
        paragraphStyle.maximumLineHeight = 22
        paragraphStyle.lineSpacing = 3
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]

        let stringAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
        ]

        for index in 0 ..< 4 {
            let string = "•\t\(points[index])"
            let label = UILabel()
            label.numberOfLines = 0
            label.attributedText = NSAttributedString(string: string,
                                                      attributes: stringAttributes)
            itemsStackView.addArrangedSubview(label)
        }

        let attributedOriginalText = NSMutableAttributedString(string: "•\t\(points.last!)")
        let hyperLink = "Competition Rules"
        let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
        let fullRange = NSMakeRange(0, attributedOriginalText.length)
        attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: fullRange)
        let linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.link,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        ] as [NSAttributedString.Key: Any]

        attributedOriginalText.addAttributes(linkTextAttributes, range: linkRange)
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = attributedOriginalText
        itemsStackView.addArrangedSubview(label)

        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCompetitionRules(_:))))
    }
}
