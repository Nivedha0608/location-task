//
//  googlemapView.swift
//  UpdatedNewProject
//
//  Created by Nivedha Moorthy on 01/07/24.
//

import UIKit
import GoogleMaps
import RealmSwift



class googlemapView: UIViewController, GMSMapViewDelegate{
    
    private var mapView: GMSMapView?
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var titleText: String?
    private var playbackButton: UIButton?
    private var playbackLocations: [LocationModel] = []
    private var playbackIndex: Int = 0
    private var playbackTimer: Timer?
    private var polyline: GMSPolyline?
    private var animatedMarker: GMSMarker?
    var realm: Realm!
    var email: String = ""
    var userId: ObjectId?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupPlaybackButton()
        initializeRealm()
        fetchAndDisplayLocationHistory()
        
    }
    
    private func setupPlaybackButton() {
        playbackButton = UIButton(type: .custom)
        playbackButton?.setImage(UIImage(named: "playbackbtn"), for: .normal)
        playbackButton?.backgroundColor = .clear
        playbackButton?.setTitleColor(.white, for: .normal)
        playbackButton?.layer.cornerRadius = 5
        playbackButton?.translatesAutoresizingMaskIntoConstraints = false
        playbackButton?.addTarget(self, action: #selector(playbackButtonTapped), for: .touchUpInside)
        
        self.view.addSubview(playbackButton!)
        
        // Add constraints
        NSLayoutConstraint.activate([
            playbackButton!.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            playbackButton!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            playbackButton!.widthAnchor.constraint(equalToConstant: 50),
            playbackButton!.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func initializeRealm() {
        do {
            realm = try Realm()
        } catch {
            print("Error initializing Realm: \(error)")
        }
    }
    
    
    private func setupMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView?.delegate = self
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView!)
        
    }
    
    @objc private func playbackButtonTapped() {
        guard !playbackLocations.isEmpty else {
            print("No location history to animate")
            return
        }
        animateLocationHistory(locations: playbackLocations)
    }
    
    private func fetchAndDisplayLocationHistory() {
        guard let userId = userId else {
            print("userId not set")
            return
        }
        
        playbackLocations = fetchLocationHistoryFromRealm(forUserId: userId)
        print("Locations fetched: \(playbackLocations.count)") // Debug line
        
        if playbackLocations.isEmpty {
            print("No locations found for the user.")
        } else {
            playbackLocations.forEach { location in
                print("Location: \(location.latitude), \(location.longitude), Timestamp: \(location.timestamp)")
            }
            // Show history markers on the map
            displayLocationHistory(locations: playbackLocations)
        }
    }
    
    private func fetchLocationHistoryFromRealm(forUserId userId: ObjectId) -> [LocationModel] {
        guard let realm = realm else {
            print("Realm is not initialized")
            return []
        }
        
        let results = realm.objects(LocationModel.self).filter("userId == %@", userId)
        return Array(results)
    }
    
    private func displayLocationHistory(locations: [LocationModel]) {
        guard !locations.isEmpty else {
            print("No locations to display")
            return
        }
        
        let path = GMSMutablePath()
        locations.forEach { location in
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            path.add(coordinate)
            let marker = GMSMarker(position: coordinate)
            marker.title = "\(location.latitude), \(location.longitude)"
            marker.snippet = "Time: \(location.timestamp)"
            marker.map = mapView
        }
        polyline?.map = nil
        polyline = GMSPolyline(path: path)
        polyline?.strokeColor = .blue
        polyline?.strokeWidth = 2.0
        polyline?.map = mapView
        print("Polyline and markers updated.")
    }
    
    
    private func animateLocationHistory(locations: [LocationModel], duration: TimeInterval = 15.0) {
        guard !locations.isEmpty else { return }
        print("Animating \(locations.count) locations.")
        let path = GMSMutablePath()
        locations.forEach { location in
            path.add(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        
        if animatedMarker == nil {
            animatedMarker = GMSMarker(position: path.coordinate(at: 0))
            animatedMarker?.map = mapView
            print("Initialized marker at first location.")
        }
        
        var index = 0
        let animationInterval = duration / Double(locations.count)
        
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if index >= locations.count {
                timer.invalidate()
                self.playbackTimer = nil
                print("Animation completed.")
                return
            }
            let location = locations[index]
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            CATransaction.begin()
            CATransaction.setAnimationDuration(animationInterval)
            self.animatedMarker?.position = coordinate
            self.mapView?.animate(toLocation: coordinate)
            CATransaction.commit()
            index += 1
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let view =  Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)![0] as! CustomInfoWindow
        view.titleLabel.text = ("   Lat: \(latitude)°N\n   Long: \(longitude)°E")
        return view
    }
    
}

