//
//  EventPreview.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 01/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.white)
            .cornerRadius(20)
            .shadow(color: Color.gray.opacity(0.5), radius: 12)
    }
}

extension View {
    func cardBackground() -> some View {
        modifier(CardBackground())
    }
}

struct EventPreview: View {
    var event: EventDisplayModel
    var onTap: (() -> Void)?
    var onJoin: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                EventTitleView(event: event)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                Spacer()
            }
            EventPhotosView(event: event)
            EventJoinersContentView(event: event, onJoin: onJoin)
            EventDescriptionView(event: event)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .cardBackground()
        .onTapGesture {
            onTap?()
        }
    }
}

struct EventTitleView: View {
    var event: EventDisplayModel
    var body: some View {
        Text(event.title)
            .font(.title3.bold())
            .multilineTextAlignment(.center)
            .overlay {
                LinearGradient(
                    colors: [.blue, .blue.opacity(0.9), .blue.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(
                    Text(event.title)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                )
            }
    }
}

struct EventPhotosView: View {
    var event: EventDisplayModel

    var body: some View {
        ZStack(alignment: .bottom) {
            EventPhotoView(photos: event.photos)
            HStack {
                Image(uiImage: UIImage(named: "Ellipse-Large")!)
                Text(event.status.status.title)
                    .foregroundStyle(Color(uiColor: event.status.status.color))
                    .font(.headline.weight(.regular))

                if let timeLeft = event.status.timeLeft {
                    Text(timeLeft)
                        .font(.headline.weight(.regular))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LinearGradient(
                        colors: [.red, .red.opacity(0.5), .red.opacity(0.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                    , lineWidth: 2)
            )
            .cornerRadius(12)
            .padding(.vertical, 40)
        }
        .frame(height: 320)
    }
}

struct EventJoinersContentView: View {
    var event: EventDisplayModel
    var onJoin: (() -> Void)?

    var body: some View {
        HStack {
            HStack(spacing: -12) {
                ForEach(event.joiners.photos, id: \.self) { photo in
                    AsyncImage(url: URL(string: photo)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .border(.black, width: 1)
                            .clipShape(Circle())
                            .frame(width: 36, height: 36)

                    } placeholder: {
                        VStack {
                        }
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 1.5))
                    }
                }
            }
            Text(event.joiners.title)
                .font(.subheadline)

            Spacer()

            EventJoinedStatusView(event: event, onJoin: onJoin)
        }
        .padding(.bottom, 8)
        .padding(.horizontal, 16)
    }
}

struct EventJoinedStatusView: View {
    var event: EventDisplayModel
    var onJoin: (() -> Void)?

    var body: some View {
        if event.joined {
            Button {
            } label: {
                HStack(alignment: .center, spacing: 0) {
                    Text("Joined")
                    Image(systemName: "checkmark")
                }
                .foregroundStyle(Color.blue)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .clipShape(Capsule())
            .frame(height: 44)

            .overlay(
                Capsule()
                    .stroke(LinearGradient(
                        colors: [.blue, .blue.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                    , lineWidth: 2)
            )

        } else {
            Button {
                onJoin?()
            } label: {
                HStack(alignment: .center, spacing: 2) {
                    Text("Join for 4")
                    Image(uiImage: UIImage(named: "CoinIcon")!)
                }
                .foregroundStyle(Color.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }

            .frame(height: 44)
            .background(
                LinearGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0.6), .blue.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(Capsule())
        }
    }
}

struct EventDescriptionView: View {
    var event: EventDisplayModel

    var body: some View {
        VStack(alignment: .leading) {
            ExpandableText(event.description, lineLimit: 3)
//                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
    }
}

#Preview {
    EventPreview(event: EventDisplayModel.sample)
}
