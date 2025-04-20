//
//  LoadingContentView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 02/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct LoadingContentView: View {
    var result: LoadingResultType
    var willDismiss: (() -> Void)?

    @State private var isLoading = true

    init(result: LoadingResultType, willDismiss: ( () -> Void)? = nil) {
        self.result = result
        self.willDismiss = willDismiss
    }
    
    var body: some View {
        VStack(alignment: .center) {
            switch result {
            case .success:
                LoadingSpinnerView(isLoading: $isLoading)
            case let .failure(loadingFailureType):
                LoadingErrorView(type: loadingFailureType, willDismiss: willDismiss)
            }
        }
        .ignoresSafeArea()
    }
}

struct LoadingContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingContentView(result: .failure(.typeA))
    }
}
