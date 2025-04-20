//
//  LocationManager.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?
    @Published var info: String?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate

        if let longitude = location?.longitude,
           let latitude = location?.latitude {
            UserSettings.shared.currentLocation = CurrentLocation(longitude: longitude, latitude: latitude)
        }

        info = "Using your current location"
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        info = "Failed, please try again"
    }
}
