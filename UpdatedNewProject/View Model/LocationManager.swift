//
//  LocationManager.swift
//  UpdatedNewProject
//
//  Created by Nivedha Moorthy on 01/07/24.
//

import CoreLocation
import UIKit
import RealmSwift


class LocationManager: NSObject{
    
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    private let realm: Realm
    private var timer: Timer?
    
    private override init() {
        self.realm = try! Realm()
        super.init()
        
        locationManager.requestAlwaysAuthorization()
        startTimer()
    }
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 900, target: self, selector: #selector(fetchAndSaveLocation), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    @objc func fetchAndSaveLocation() {
        locationManager.requestLocation()
    }
    private func saveLocation(_ location: CLLocation) {
        //           guard let userId = currentUserId else { return }
        
        let newLocation = LocationModel()
        newLocation.latitude = location.coordinate.latitude
        newLocation.longitude = location.coordinate.longitude
        newLocation.timestamp = location.timestamp
        
        do {
            try realm.write {
                realm.add(newLocation)
            }
        } catch {
            print("Error saving location to Realm: \(error.localizedDescription)")
        }
    }
    
    
    
    
}
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        saveLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }
}

