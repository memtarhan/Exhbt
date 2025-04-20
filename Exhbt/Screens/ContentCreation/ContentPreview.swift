//
//  ContentPreview.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct ContentPreview: View {
    let asset: CCAsset
    var completion: (_ cancelled: Bool) -> Void

    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                Spacer()
                
                if let image = asset.image {
                    PhotoPreview(image: image)
//                        .frame(width: geometry.size.width, height: geometry.size.width * asset.aspectRatio)

                    
                } else if let videoURL = asset.videoURL {
                    VideoPreview(url: videoURL)
                        .frame(width: geometry.size.width, height: geometry.size.width * asset.aspectRatio)
                }
                
                Spacer()
                
                HStack(spacing: 32) {
                    Button("Cancel") {
                        completion(true)
                    }
                    
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button("Confirm") {
                        completion(false)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.blue)
                }
            }
        }
    }
}

private struct PhotoPreview: View {
    let image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .aspectRatio(contentMode: .fit)
            .padding()
    }
}

private struct VideoPreview: View {
    let url: URL
    var body: some View {
        VideoContainerView(showControls: false, url: url)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
    }
}

#Preview {
    ContentPreview(asset: CCAsset(type: .video, image: nil, videoURL: URL(string: "https://res.cloudinary.com/htofkinpe/video/upload/sp_auto/v1701963102/tests/2.m3u8")!, thumbnail: nil, aspectRatio: 9 / 16)) { cancelled in
        print("cancelled: \(cancelled)")
    }
}
