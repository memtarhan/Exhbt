//
//  FilterView.swift
//  Exhbt
//
//  Created by Adem Tarhan on 18.10.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import CoreLocationUI
import SwiftUI

struct FilterView: View {
    @State private var selectedAllEvents = LocalStorage.shared.showAllEvents
    @State private var selectedSortByLocation = LocalStorage.shared.sortEventsByLocation
    @State private var selectedShowNSFWContent = LocalStorage.shared.showNSFWEvents

    private var showAllEvents = LocalStorage.shared.showAllEvents
    private var sortByLocation = LocalStorage.shared.sortEventsByLocation
    private var showNSFWContent = LocalStorage.shared.showNSFWEvents

    @StateObject var locationManager = LocationManager()

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Show Events:")
                    .font(.system(size: 15, weight: .bold))

                HStack {
                    Toggle(isOn: $selectedAllEvents.not) {
                    }
                    .toggleStyle(CircleCheckboxToggleStyle())

                    Text("My Events")
                        .font(.system(size: 15))
                }

                HStack {
                    Toggle(isOn: $selectedAllEvents) {
                    }
                    .toggleStyle(CircleCheckboxToggleStyle())

                    Text("Explore All")
                        .font(.system(size: 15))
                }
            }
            .padding(.horizontal, 15)

            VStack(alignment: .leading, spacing: 16) {
                Text("Sort by:")
                    .font(.system(size: 15, weight: .bold))

                HStack {
                    Toggle(isOn: $selectedSortByLocation) {
                    }
                    .toggleStyle(SquareCheckboxToggleStyle())
                    .onChange(of: selectedSortByLocation) { _ in
                        selectedSortByLocation.toggle()
                        LocalStorage.shared.sortEventsByLocation = selectedSortByLocation
                    }

                    Text("Location proximity")
                        .font(.system(size: 15))

                    Spacer()

                    VStack {
                        if selectedSortByLocation {
                            LocationButton(.currentLocation) {
                                locationManager.requestLocation()
                            }
                            .clipShape(Capsule())

                            if let info = locationManager.info {
                                Text(info)
                                    .font(.system(size: 10, weight: .ultraLight))
                            }
                        }
                    }
                }
                .frame(height: 44)

                Divider()

                HStack {
                    Toggle(isOn: $selectedShowNSFWContent) {
                    }
                    .toggleStyle(SquareCheckboxToggleStyle())
                    .onChange(of: selectedShowNSFWContent) { _ in
                        selectedShowNSFWContent.toggle()
                        LocalStorage.shared.showNSFWEvents = selectedShowNSFWContent
                    }
                    Text("Show NSFW content")
                        .font(.system(size: 15))
                }
            }
            .padding()
        }
        .clipShape(
            .rect(
                topLeadingRadius: 0,
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 20,
                topTrailingRadius: 0
            )
        )

        .onDisappear {
            LocalStorage.shared.showAllEvents = selectedAllEvents
            let updatedFilters =
                (showAllEvents != LocalStorage.shared.showAllEvents) ||
                (sortByLocation != LocalStorage.shared.sortEventsByLocation) ||
                (showNSFWContent != LocalStorage.shared.showNSFWEvents)

            if updatedFilters { AppState.shared.updatedEventFilters.send() }
        }
    }
}

#Preview {
    FilterView()
}

struct CircleCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()

        }, label: {
            HStack {
                if configuration.isOn {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.blue)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.blue, lineWidth: 2)
                        }
                } else {
                    Image(systemName: "circle")
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 2)
                        }
                }
                configuration.label
            }
        })
    }
}

struct SquareCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                if configuration.isOn {
                    RoundedRectangle(cornerRadius: 5.0)
                        .stroke(lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .cornerRadius(5.0)
                        .foregroundStyle(.blue)
                        .overlay {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundStyle(.blue)
                        }
                } else {
                    RoundedRectangle(cornerRadius: 5.0)
                        .stroke(lineWidth: 3)
                        .frame(width: 20, height: 20)
                        .cornerRadius(5.0)
                        .foregroundStyle(.black)
                }
                configuration.label
            }
        }

        /*

         HStack {
             if configuration.isOn {
                 RoundedRectangle(cornerRadius: 5.0)
                     .stroke(lineWidth: 2)
                     .frame(width: 20, height: 20)
                     .cornerRadius(5.0)
                     .foregroundStyle(.blue)
                     .overlay {
                         Image(systemName: "checkmark.square.fill")
                             .foregroundStyle(.blue)
                     }
                     .onTapGesture {
                         withAnimation(.spring()) {
                             configuration.isOn.toggle()
                         }
                     }

             } else {
                 RoundedRectangle(cornerRadius: 5.0)
                     .stroke(lineWidth: 3)
                     .frame(width: 20, height: 20)
                     .cornerRadius(5.0)
                     .foregroundStyle(.black)
                     .onTapGesture {
                         withAnimation(.spring()) {
                             configuration.isOn.toggle()
                         }
                     }
             }

             configuration.label
         }

          */
    }
}
