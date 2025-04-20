//
//  ImageViewerViewer.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Kingfisher
import UIKit

class ImageViewerViewer: UIViewController {
    private var url: URL?
    private var image: UIImage?

    init(withURL url: URL?, image: UIImage? = nil) {
        super.init(nibName: nil, bundle: nil)

        self.url = url
        self.image = image

        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "xmark.circle.fill")
        configuration.baseForegroundColor = .white

        let button = UIButton(configuration: configuration, primaryAction: UIAction { _ in
            self.dismiss(animated: true)
        })
        button.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        imageView.loadImage(withURL: url)
    }
}
