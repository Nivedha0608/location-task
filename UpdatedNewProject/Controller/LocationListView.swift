//
//  LocationListView.swift
//  UpdatedNewProject
//
//  Created by Nivedha Moorthy on 01/07/24.
//

import UIKit
import RealmSwift
import CoreLocation


class LocationListView: UIViewController {
    
    @IBOutlet weak var listview: UITableView!
    
    @IBOutlet weak var titlelbl: UILabel!
    var locations: Results<LocationModel>?
    var realm = try! Realm()
    var notificationToken: NotificationToken?
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var email: String = ""
    var id : ObjectId?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        setupTableView()
        fetchLocationsFromRealm()
        titlelbl.text = "Location List"
        setupRealm()
        print("ni--->user latitude = \(latitude)")
        print("ni-->user longitude = \(longitude)")
        print("ni--->userid = \(String(describing: id))")
        
    }
    
    private func setupTableView() {
        listview.delegate = self
        listview.dataSource = self
        listview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupRealm() {
        do {
            realm = try Realm()
        } catch {
            print("Error initializing Realm: \(error.localizedDescription)")
        }
    }
    
    
    
    private func fetchLocationsFromRealm() {
        guard let userId = fetchUserIdFromEmail(email) else {
            print("User ID not found for email: \(email)")
            return
        }
        
        let results = realm.objects(LocationModel.self).filter("userId == %@", userId)
        
        notificationToken = results.observe { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial(let initialResults):
                self.locations = initialResults
                self.listview.reloadData()
            case .update(let updatedResults, let deletions, let insertions, let modifications):
                self.locations = updatedResults
                self.listview.beginUpdates()
                self.listview.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.listview.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.listview.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.listview.endUpdates()
            case .error(let error):
                print("Realm error: \(error.localizedDescription)")
            }
        }
    }
    private func fetchUserIdFromEmail(_ email: String) -> ObjectId? {
        guard let user = realm.objects(User.self).filter("email == %@", email).first else {
            print("No user found for email: \(email)")
            return nil
        }
        return user._id
    }
    
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension LocationListView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations?.count ?? 0
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let location = locations?[indexPath.row] {
            cell.textLabel?.text = "Lat: \(location.latitude), Long: \(location.longitude)"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        let location = locations?[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let googleMapVC = storyboard.instantiateViewController(withIdentifier: "googlemapView") as? googlemapView {
            googleMapVC.latitude = location?.latitude ?? 0.00
            googleMapVC.longitude = location?.longitude ?? 0.00
            googleMapVC.titleText = "Location at \(location?.latitude ?? 0.00), \(location?.longitude ?? 0.00)"
            googleMapVC.email = email
            googleMapVC.userId = id
            self.navigationController?.pushViewController(googleMapVC, animated: true)
        }
    }
    
}

