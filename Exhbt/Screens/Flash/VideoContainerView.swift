//
//  VideoContainerView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 09/07/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import AVKit
import SwiftUI
import UIKit

struct VideoContainerView: View {
    var showControls = true

    private var player: AVPlayer?

    @State private var isMuted = true
    @State private var isPlaying = true

    init(showControls: Bool = true, url: URL) {
        self.showControls = showControls
        player = AVPlayer(url: url)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let player {
                PlayerContainerView(player: player, gravity: .aspectFill)
                    .onAppear {
                        player.isMuted = isMuted
                        player.seek(to: .zero)
                        if isPlaying {
                            player.play()

                        } else {
                            player.pause()
                        }
                    }

                    .onDisappear {
                        player.pause()
                        isPlaying = false
                    }

                    .onReceive(NotificationCenter.default.publisher(
                        for: UIScene.willEnterForegroundNotification)) { _ in
                            player.isMuted = isMuted
                            player.play()
                            isPlaying = true
                    }

                    .onReceive(NotificationCenter.default.publisher(
                        for: UIScene.didEnterBackgroundNotification)) { _ in
                            player.pause()
                            isPlaying = false
                    }

                if showControls {
                    HStack(alignment: .bottom) {
                        Button {
                            if player.isPlaying {
                                player.pause()

                            } else {
                                player.play()
                            }
                            isPlaying.toggle()

                        } label: {
                            Image(systemName: isPlaying ? "play.slash.fill" : "play.fill")
                                .font(.title)
                                .tint(.blue)
                        }

                        Spacer()

                        Button {
                            player.isMuted = !player.isMuted
                            isMuted.toggle()
                        } label: {
                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.fill")
                                .font(.title)
                                .tint(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 20)
                    .background(.ultraThinMaterial)
                    .onDisappear {
                        print("onDisappear")
                        player.pause()
                    }
                }
            }
        }
    }
}

struct SimpleVideoContainerView: View {
    var showControls = true

    private var player: AVPlayer?

    @State private var isPlaying = true

    init(url: URL) {
        player = AVPlayer(url: url)
    }

    var body: some View {
        ZStack(alignment: .center) {
            if let player {
                PlayerContainerView(player: player, gravity: .aspectFill)
                    .onAppear {
                        player.seek(to: .zero)
                        if isPlaying {
                            player.play()

                        } else {
                            player.pause()
                        }
                    }

                    .onDisappear {
                        player.pause()
                        isPlaying = false
                    }

                    .onReceive(NotificationCenter.default.publisher(
                        for: UIScene.willEnterForegroundNotification)) { _ in
                            player.play()
                            isPlaying = true
                    }

                    .onReceive(NotificationCenter.default.publisher(
                        for: UIScene.didEnterBackgroundNotification)) { _ in
                            player.pause()
                            isPlaying = false
                    }
                    .onTapGesture {
                        isPlaying.toggle()
                    }
            }
        }
    }
}

enum PlayerGravity {
    case aspectFill
    case resize
}

class PlayerView: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }

    let gravity: PlayerGravity

    init(player: AVPlayer, gravity: PlayerGravity) {
        self.gravity = gravity
        super.init(frame: .zero)
        self.player = player
        backgroundColor = .black
        setupLayer()
    }

    func setupLayer() {
        switch gravity {
        case .aspectFill:
            playerLayer.contentsGravity = .resizeAspectFill
            playerLayer.videoGravity = .resizeAspectFill

        case .resize:
            playerLayer.contentsGravity = .resize
            playerLayer.videoGravity = .resize
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

struct PlayerContainerView: UIViewRepresentable {
    typealias UIViewType = PlayerView

    let player: AVPlayer
    let gravity: PlayerGravity

    init(player: AVPlayer, gravity: PlayerGravity) {
        self.player = player
        self.gravity = gravity
    }

    func makeUIView(context: Context) -> PlayerView {
        return PlayerView(player: player, gravity: gravity)
    }

    func updateUIView(_ uiView: PlayerView, context: Context) { }
}

struct VideoContainerView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleVideoContainerView(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
            .frame(width: 270, height: 640)
    }
}
