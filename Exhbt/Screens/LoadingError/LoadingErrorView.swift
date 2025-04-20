//
//  LoadingError.swift
//  Exhbt
//
//  Created by Adem Tarhan on 28.08.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct LoadingErrorView: View {
    var type: LoadingFailureType
    var willDismiss: (() -> Void)?

    init(type: LoadingFailureType, willDismiss: (() -> Void)? = nil) {
        self.type = type
        self.willDismiss = willDismiss
    }

    var body: some View {
        VStack {
            if type == .typeA {
                ErrorViewTypeA(willDismiss: willDismiss)
            } else {
                ErrorViewTypeB(willDismiss: willDismiss)
            }
        }
    }
}

struct ErrorViewTypeA: View {
    var willDismiss: (() -> Void)?

    init(willDismiss: (() -> Void)? = nil) {
        self.willDismiss = willDismiss
    }

    var body: some View {
        VStack {
            Image("error1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .edgesIgnoringSafeArea(.top)

            Spacer()

            VStack {
                Text("🫣Oh snap!")
                    .font(.system(size: 36, weight: .bold))
                    .padding(.bottom, 10)

                Text("Something went wrong with this page. You can look at Metro Boomin  endlessly or go back to previous page and take it from scratch.")
                    .font(.system(size: 16))
                    .font(.body).fontWeight(.medium)
                    .padding(.horizontal, 70)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button("Go Back") {
                willDismiss?()
            }
            .buttonStyle(MainButtonStyle())
        }
    }
}

struct ErrorViewTypeB: View {
    var willDismiss: (() -> Void)?

    init(willDismiss: (() -> Void)? = nil) {
        self.willDismiss = willDismiss
    }

    var body: some View {
        VStack {
            ZStack {
                Image("error3").aspectRatio(contentMode: .fit)

                Text("🫣Oh snap!")
                    .font(.system(size: 36, weight: .bold))
                    .padding(.top, 40)
            }

            Text("Something went wrong with this page. You can look at Metro Boomin  endlessly or go back to previous page and take it from scratch.")
                .font(.system(size: 16, weight: .medium))

                .padding(.horizontal, 70)
                .padding(.bottom, 60)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)

            Spacer()
            Image("error2")
                .scaledToFit()

            Spacer()
            Button("Go Back") {
                willDismiss?()
            }.buttonStyle(MainButtonStyle())
        }
        .ignoresSafeArea()
    }
}

struct LoadingError_Previews: PreviewProvider {
    static var previews: some View {
        ErrorViewTypeA {
        }
    }
}
