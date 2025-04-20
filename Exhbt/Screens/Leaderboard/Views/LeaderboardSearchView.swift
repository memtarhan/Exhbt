//
//  LeaderboardSearchView.swift
//  Exhbt
//
//  Created by Kemal Ekren on 3.08.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

enum LeaderboardSearchConstant {
    static let placeholderText: String = "Search"
    static let searchBarIconName: String = "searchIcon"
    static let searchBarBorderColor: Color = Color("LeaderboardSearchBarBorder")
    static let searchBarPlaceholderColor: Color = Color("LeaderboardSearchBarPlaceHolderColor")
}

struct LeaderboardSearchView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            TextField(text: $searchText) {
                Text(LeaderboardSearchConstant.placeholderText)
                    .foregroundColor(LeaderboardSearchConstant.searchBarPlaceholderColor)
                    .padding(.leading, 5)
            }
            .frame(maxWidth: .infinity)
            .keyboardType(.webSearch)
            .tint(Color("LogoGradientBlue"))
            .padding(.leading, 16)
            
            Image(LeaderboardSearchConstant.searchBarIconName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(.trailing, 16)
        }
        .frame(height: 45)
        .overlay(content: {
            RoundedRectangle(cornerRadius: 48)
                .stroke(LeaderboardSearchConstant.searchBarBorderColor ,lineWidth: 1)
        })
    }
}

struct LeaderboardSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardSearchView(searchText: .constant(""))
    }
}
