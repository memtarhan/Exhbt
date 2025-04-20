//
//  UIColor+.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 22/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

extension UIColor {
    public class var primaryRed: UIColor? { return UIColor(named: "PrimaryRed") }
    public class var backgroundPrimaryWithOpacity: UIColor? { return UIColor(named: "BackgroundPrimaryWithOpacity") }
    public class var titleBackgroundWithOpacity: UIColor? { return UIColor(named: "TitleBackgroundWithOpacity") }
    public class var competitionBackgroundColor: UIColor? { return UIColor(named: "CompetitionBackgroundColor") }
    public class var exhbtSecondaryBackground: UIColor? { return UIColor(named: "ExhbtSecondaryBackground") }
    public class var exhbtGray: UIColor? { return UIColor(named: "ExhbtGrey") }
    public class var readNotificationBackgroundColor: UIColor? { return UIColor(named: "ReadNotificationBackgroundColor") }
    public class var mainBlack: UIColor? { return UIColor(named: "MainBlack") }
    public class var exhbtStatusWaiting: UIColor? { return UIColor(named: "ExhbtStatusWaiting") }
    public class var exhbtStatusLive: UIColor? { return UIColor(named: "ExhbtStatusLive") }
    public class var unvotedStatus: UIColor? { return UIColor(named: "VoteStatus - Unvoted") }
    public class var votedStatus: UIColor? { return UIColor.systemBlue }

    public class var logoGradientBlue: UIColor { return UIColor(named: "LogoGradientBlue")! }
    public class var logoGradientLightPurple: UIColor { return UIColor(named: "LogoGradientDarkPurple")! }
    public class var logoGradientDarkPurple: UIColor { return UIColor(named: "LogoGradientDarkPurple")! }

    public class var blueGradientButtonLeftColor: UIColor { return UIColor(named: "BlueGradientButtonLeftColor")! }
    public class var blueGradientButtonMiddleColor: UIColor { return UIColor(named: "BlueGradientButtonMiddleColor")! }
    public class var blueGradientButtonRightColor: UIColor { return UIColor(named: "BlueGradientButtonRightColor")! }

    public class var lineGradientLeftColor: UIColor { return UIColor(named: "LineGradientLeftColor")! }
    public class var lineGradientRightColor: UIColor { return UIColor(named: "LineGradientRightColor")! }

    public class var textBoxBackgroundColor: UIColor { return UIColor(named: "TextBoxBackgroundColor")! }
}
