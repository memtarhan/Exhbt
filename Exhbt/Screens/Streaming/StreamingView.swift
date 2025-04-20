//
//  StreamingView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 07/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import AVFoundation
import AVKit
import SwiftUI

final class LoopedVideoPlayerView: UIView {
    fileprivate var videoURL: URL?
    fileprivate var queuePlayer: AVQueuePlayer?
    fileprivate var playerLayer: AVPlayerLayer?
    fileprivate var playbackLooper: AVPlayerLooper?

    func prepareVideo(_ videoURL: URL) {
        let playerItem = AVPlayerItem(url: videoURL)

        self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.playerLayer = AVPlayerLayer(player: self.queuePlayer)
        guard let playerLayer = playerLayer else { return }
        guard let queuePlayer = queuePlayer else { return }
        playbackLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)

        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = frame
        layer.addSublayer(playerLayer)
    }

    func play() {
        queuePlayer?.play()
    }

    func pause() {
        queuePlayer?.pause()
    }

    func stop() {
        queuePlayer?.pause()
        queuePlayer?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
    }

    func unload() {
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        queuePlayer = nil
        playbackLooper = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        playerLayer?.frame = bounds
    }
}

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = numberOfPages
        pageControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged)

        return pageControl
    }

    func updateUIView(_ pageControl: UIPageControl, context: Context) {
        pageControl.currentPage = currentPage
    }

    class Coordinator: NSObject {
        var pageControl: PageControl

        init(_ pageControl: PageControl) {
            self.pageControl = pageControl
        }

        @objc func updateCurrentPage(sender: UIPageControl) {
            pageControl.currentPage = sender.currentPage
        }
    }
}

struct StreamingPlayerView: UIViewRepresentable {
    let videoURL: URL
    @Binding var isPlaying: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> LoopedVideoPlayerView {
        let view = LoopedVideoPlayerView()
        view.prepareVideo(videoURL)

        return view
    }

    func updateUIView(_ videoPlayer: LoopedVideoPlayerView, context: Context) {
        isPlaying ? videoPlayer.play() : videoPlayer.pause()
    }

    class Coordinator: NSObject {
        var playerView: StreamingPlayerView

        init(_ playerView: StreamingPlayerView) {
            self.playerView = playerView
        }

        @objc
        func play() {
            playerView.isPlaying = true
        }
    }
}

// struct StreamingPlayerView: UIViewControllerRepresentable {
//    var videoURL: URL
//
//    func makeUIViewController(context: Context) -> AVPlayerViewController {
//        let playerItem = AVPlayerItem(url: videoURL)
//        let player = AVPlayer(playerItem: playerItem)
////        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
////        let playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
//
//        let playerController = AVPlayerViewController()
//        playerController.player = player
//        playerController.showsPlaybackControls = false
//        playerController.view.backgroundColor = .clear
//        player.play()
//        return playerController
//    }
//
//    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
// }

///  A simple streaming container without any controls.
///  Plays the video in a loop
struct SimpleStreamingView: View {
    private let videoURL: URL
    private let cornerRadius: CGFloat

    /// Initializes a simple straming container without any controls
    /// - Parameters:
    ///   - videoURL: The video URL to be played. It should be a valid URL, otherwise, it won't play
    ///   - cornerRadius: The corner radius of the container. For flat container, pass 0
    init(videoURL: URL, cornerRadius: CGFloat) {
        self.videoURL = videoURL
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        GeometryReader { geometry in
            StreamingPlayerView(videoURL: videoURL, isPlaying: .constant(true))
                .frame(width: geometry.size.width, height: (geometry.size.width) * (9 / 16))
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

///  A basic streaming container with play button in middle and play/pause functionalities
///  Plays the video in a loop, allows you to play and pause the video
struct BasicStreamingView: View {
    private let model: StreamingModel
    private let cornerRadius: CGFloat

    @State private var isPlaying = false

    /// Initializes a simple straming container without any controls
    /// - Parameters:
    ///   - model: The model with  video details  to be played. It should be a valid video URL, an optional thumbnail URL and aspect ratio
    ///   - cornerRadius: The corner radius of the container. For flat container, pass 0
    init(model: StreamingModel, cornerRadius: CGFloat) {
        self.model = model
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                StreamingPlayerView(videoURL: model.videoURL, isPlaying: $isPlaying)
                    .frame(width: geometry.size.width, height: (geometry.size.width) * (9 / 16))
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

                Button {
                    isPlaying.toggle()

                } label: {
                    if !isPlaying {
                        Image(systemName: "play.fill")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.blue)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())

                    } else {
                        VStack {
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct StreamingList: View {
    var body: some View {
        GeometryReader { geometry in

            List {
                BasicStreamingView(model: StreamingModel.sample, cornerRadius: 12)
                    .frame(width: (geometry.size.width - 32), height: (geometry.size.width - 32) * StreamingModel.sample.aspectRatio)
                

                BasicStreamingView(model: StreamingModel.sample, cornerRadius: 12)
                    .frame(width: (geometry.size.width - 32), height: (geometry.size.width - 32) * StreamingModel.sample.aspectRatio)
                
                BasicStreamingView(model: StreamingModel.sample, cornerRadius: 12)
                    .frame(width: (geometry.size.width - 32), height: (geometry.size.width - 32) * StreamingModel.sample.aspectRatio)
                
                BasicStreamingView(model: StreamingModel.sample, cornerRadius: 12)
                    .frame(width: (geometry.size.width - 32), height: (geometry.size.width - 32) * StreamingModel.sample.aspectRatio)
                
                BasicStreamingView(model: StreamingModel.sample, cornerRadius: 12)
                    .frame(width: (geometry.size.width - 32), height: (geometry.size.width - 32) * StreamingModel.sample.aspectRatio)
                
                BasicStreamingView(model: StreamingModel.sample, cornerRadius: 12)
                    .frame(width: (geometry.size.width - 32), height: (geometry.size.width - 32) * StreamingModel.sample.aspectRatio)
                
                BasicStreamingView(model: StreamingModel.sample, cornerRadius: 12)
                    .frame(width: (geometry.size.width - 32), height: (geometry.size.width - 32) * StreamingModel.sample.aspectRatio)
            }
            .listStyle(.plain)
            .padding()
        }
    }
}

struct StreamingModel {
    let videoURL: URL
    let thumbnailURL: URL?
    let aspectRatio: Double

    static let sample = StreamingModel(videoURL: sampleURL, thumbnailURL: nil, aspectRatio: 1280 / 1920)
}

fileprivate let sampleURL = URL(string: "https://res.cloudinary.com/htofkinpe/video/upload/sp_auto/v1702129974/tests/10.m3u8")!

#Preview {
    StreamingList()
}
