//
//  ContentPermissionsView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 30/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct ContentPermissionsView: View {
    var completion: (_ continued: Bool) -> Void

    var body: some View {
        VStack {
            Spacer()

            Text("Access Your Photos From Exhbt")
                .font(.title3.weight(.medium))
                .multilineTextAlignment(.center)
                .padding()

            PermissionsInfoView()
                .padding()

            Spacer()

            Text("Select Allow Access to All Photos to access your whole camera roll from Exhbt.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(20)

            Button("Continue") {
                completion(true)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.blue)
            .padding()
        }
    }
}

struct PermissionsInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                Text("You’ll be given options to access all of your photos from Exhbt or manually select a few.")
                    .font(.system(size: 15))
            }

            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield")
                Text("You’re in control. You decide what photos you share.")
                    .font(.system(size: 15))
            }

            HStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                Text("It’s easier to share on Exhbt when you can access your whole camera roll.")
                    .font(.system(size: 15))
            }
        }
    }
}

#Preview {
    ContentPermissionsView { _ in
        
    }
}
