//
//  TermsPrivacyView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 15/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct TermsPrivacyView: View {
    let string: AttributedString

    init() {
        var string = AttributedString("By continuing you agree to ")
        var terms = AttributedString("\nTerms of Use")
        terms.link = URL(string: Links.terms)
        terms.foregroundColor = .link

        string.append(terms)
        
        string.append(AttributedString(" and "))
        
        var privacy = AttributedString("Privacy Policy")
        privacy.link = URL(string: Links.privacy)
        privacy.foregroundColor = .link

        string.append(privacy)

        self.string = string
    }

    var body: some View {
        Text(string)
            .environment(\.openURL, OpenURLAction { _ in
                return .systemAction
            })
            .font(.headline)
            .padding()
            .multilineTextAlignment(.center)
    }
}

#Preview {
    TermsPrivacyView()
}
