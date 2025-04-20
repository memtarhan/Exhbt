//
//  EventResultTopRanksView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct EventResultBottomRanksView: View {
    var data: [LeaderboardUserDisplayModel]
    var onSelection: ((_ userId: Int) -> Void)?

    var body: some View {
        List {
            ForEach(data, id: \.self) { user in
                HStack {
                    AsyncImage(url: URL(string: user.photoURL ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Color.blue
                    }

                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    
                    
                    if let username = user.username {
                        Text(username)
                            .foregroundStyle(Color.white)
                        
                    }
                    
                    Spacer()
                    
                    Text(user.score)
                        .foregroundStyle(Color.white)
                }
                
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(uiColor: UIColor(named: "ListBackgroundPrimary")!))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                

            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .padding(.bottom, 64)
        }
        .listStyle(.plain)
        .background(Color(uiColor: UIColor(named: "ListBackgroundSecondary")!))
    }
}

#Preview {
    EventResultBottomRanksView(data: [LeaderboardUserDisplayModel.sample])
}
