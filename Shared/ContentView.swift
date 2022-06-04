//
//  ContentView.swift
//  Shared
//
//  Created by T Rayle on 4/9/22.
//
import CoreLocation
import CoreLocationUI

import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var startLocation: CLLocation?
    var traveledDistance = 0.0
    var straightDistance: Double {
        guard let lastLocation = lastLocation else {
            return 0
        }
        guard let startLocation = startLocation else {
            return 0
        }
        return startLocation.distance(from: lastLocation)
    }
    var authorized = false
    var startTime = Date.now
    var elapsedTime: TimeInterval = 0
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        authorized = manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        startTime = Date.now
    }

    func stopLocation() {
        manager.stopUpdatingLocation()
        lastLocation = nil
        startLocation = nil
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        guard startLocation != nil else {
            startLocation = location
            return
        }
        guard let lastLocation = lastLocation else {
            lastLocation = location
            return
        }

        traveledDistance += lastLocation.distance(from: location)
        self.lastLocation = location
        elapsedTime = Date.now.timeIntervalSince(startTime)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorized = manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

struct ContentView: View {
    @StateObject var locationManager = LocationManager()

    var body: some View {
        VStack {
            if !locationManager.authorized {
                Text("This app will ask for permission to see your location.")
            }
            else {
                Text("Travelled Distance: \(locationManager.traveledDistance)")
            }
            if let location = locationManager.lastLocation {
                Text("Straight Distance: \(locationManager.straightDistance)")
                Text("Your speed: \(location.speed)")
                Text("Elapsed time: \(locationManager.elapsedTime)")
                Text("Latitude: \(location.coordinate.latitude)")
                Text("Longitude: \(location.coordinate.longitude)")
                Button(action: locationManager.stopLocation) {
                    Text("Stop Recording")
                }
            }
            else {
                Button(action: locationManager.requestLocation) {
                    Text("Start Recording")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}
