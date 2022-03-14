//
//  Label.swift
//  Exhbt
//
//  Created by Shouvik Paul on 5/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

enum FontWeight: String {
    case regular = "HelveticaNeue"
    case semiBold = "HelveticaNeue-Medium"
    case bold = "HelveticaNeue-Bold"
    
    case boldItalic = "HelveticaNeue-BoldItalic"
}

class Label: UILabel {
    
    init(
        title: String,
        fontSize: CGFloat = 16,
        weight: FontWeight = .regular
    ) {
        super.init(frame: .zero)
        
        self.text = title
        self.textColor = .DarkGray()
        
        self.font = UIFont(name: weight.rawValue, size: fontSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CenteredLabel: UILabel {
    
    init(
        title: String,
        fontSize: CGFloat = 16,
        weight: FontWeight = .regular
    ) {
        super.init(frame: .zero)
        
        self.text = title
        self.textColor = .DarkGray()
        self.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.numberOfLines = 0
        self.textAlignment = .center
        
        self.font = UIFont(name: weight.rawValue, size: fontSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
