//
//  FollowsContentView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 05/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct FollowsDisplayModel: Identifiable {
    let id: Int
    let photoURL: URL?
    let username: String
}

struct FollowsContentView: View {
    @State var selectedSegment = 0
    @State private var searchText = ""

    private let models = (0 ..< 5).enumerated().map {
        FollowsDisplayModel(id: $1, photoURL: URL(string: "https://images.pexels.com/photos/16141305/pexels-photo-16141305/free-photo-of-view-of-a-white-building.jpeg?auto=compress&cs=tinysrgb&h=240&dpr=2"), username: "user\($1)")
    }

    var body: some View {
        List {
            searchBar

            Picker("", selection: $selectedSegment) {
                Text("Followers").tag(0)
                Text("Followings").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 8)
            .listRowSeparator(.hidden)

            ForEach(models) { model in
                HStack {
                    AsyncImage(url: model.photoURL) { image in
                        image.resizable()
                    } placeholder: {
                        Color.blue
                    }

                    .frame(width: 48, height: 48)
                    .clipShape(Circle())

                    Text(model.username)

                    Spacer()

                    Button("Follow") {
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
            .listRowSeparator(.hidden)
        }

        .navigationBarHidden(true)
        .listStyle(.plain)
        .padding(.horizontal, 8)
    }

    // MARK: searchBar

    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search by username", text: $searchText)
                .font(Font.system(size: 21))
        }
        .padding(7)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // TODO: Fix search logic
    var searchResults: [FollowsDisplayModel] {
        if searchText.isEmpty {
            return models
        } else {
            return models.filter { $0.username.contains(searchText) }
        }
    }
}

struct FollowsContentView_Previews: PreviewProvider {
    static var previews: some View {
        FollowsContentView()
    }
}
