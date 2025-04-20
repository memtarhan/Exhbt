//
//  ExhbtWinnerView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 20/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct WinnerModel {
    let backgroundImageURL: URL
    let username: String?
    let profileImageURL: URL?

    static func from(response: WinnerResponse) -> WinnerModel {
        WinnerModel(backgroundImageURL: URL(string: response.backgroundImage)!,
                    username: response.username,
                    profileImageURL: URL(string: response.profileImage ?? ""))
    }

    static let sample = WinnerModel(backgroundImageURL: URL(string: "https://res.cloudinary.com/htofkinpe/image/upload/v1/competitions/156")!,
                                    username: "memtarhan",
                                    profileImageURL: URL(string: "https://res.cloudinary.com/htofkinpe/image/upload/v1/competitions/156")!)
}

struct WinnerView: View {
    let winner: WinnerModel
    var onContinue: () -> Void

    var body: some View {
        ZStack(alignment: .center) {
            WinnerBackgroundImageView(url: winner.backgroundImageURL)
                .blur(radius: 7)
                .ignoresSafeArea()

            VStack {
                Text(" 🎉 The winner is")
                    .foregroundStyle(Color.white)
                    .font(.title.bold())
                Spacer()
                if let profileImageURL = winner.profileImageURL {
                    WinnerProfileImageView(url: profileImageURL)
                }
                Spacer()
                if let username = winner.username {
                    Text(username)
                        .foregroundStyle(Color.white)
                        .font(.headline)
                        .padding()
                }
                WinnerContinueButton(onContinue: onContinue)
            }
            .padding(.vertical, 128)
        }
    }
}

struct WinnerBackgroundImageView: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)

        } placeholder: {
        }
    }
}

struct WinnerProfileImageView: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .border(.black, width: 1)
                .clipShape(Circle())
                .frame(width: 100, height: 100)

        } placeholder: {
        }
    }
}

struct WinnerContinueButton: View {
    var onContinue: () -> Void

    var body: some View {
        Button("Continue") {
            onContinue()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 64)
        .foregroundColor(.white)
        .background(
            LinearGradient(gradient: Gradient(colors: [.blue, .blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    WinnerView(winner: WinnerModel.sample) {
    }
}
