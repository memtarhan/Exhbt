//
//  LoadingSpinnerView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 02/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct LoadingSpinnerView: View {
    @Binding var isLoading: Bool

    private let gradient = AngularGradient(
        gradient: Gradient(colors: [Color.blue, .white]),
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(330)
    )

    var body: some View {
        VStack {
            Circle()
                .trim(from: 0.0, to: 0.9)
                .stroke(gradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(Angle(degrees: isLoading ? 0 : 360))
                .onAppear {
                    withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                        isLoading.toggle()
                    }
                }

        }.frame(width: 45, height: 45)
    }
}

struct LoadingSpinnerView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingSpinnerView(isLoading: .constant(true))
    }
}
