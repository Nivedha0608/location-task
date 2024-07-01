//
//  LoginView.swift
//  UpdatedNewProject
//
//  Created by Nivedha Moorthy on 01/07/24.
//

import UIKit
import RealmSwift
import CoreLocation

class LoginView: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var donthavelabel: UILabel!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var logostackview: UIStackView!
    @IBOutlet weak var imageview: UIImageView!
    
    var realm: Realm!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        setupKeyboardDismissal()
        requestLocationPermissions()
        do {
            realm = try Realm()  // Initialize realm object
        } catch {
            print("Error initializing Realm: \(error)")
        }
        
    }
    
    func setupKeyboardDismissal() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupUI() {
        donthavelabel.text = "Dont have an account?  "
        donthavelabel.textColor = .white
        login.layer.cornerRadius = 5
        logostackview.layer.cornerRadius = 10
        imageview.layer.cornerRadius = 10
        
    }
    func requestLocationPermissions() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        guard let email = userTextField.text,
              let password = passwordTextField.text else {
            print("Invalid input")
            return
        }
        
        do {
            let realm = try Realm()
            if let user = realm.objects(User.self).filter("email == %@ AND password == %@", email, password).first {
                locationManager.requestLocation()
                // Pass the `user` object to `showSuccessMessage`
                showSuccessMessage(on: self, title: "Success", message: "Login successful.", user: user)
            } else {
                print("Invalid credentials")
                showAlert(message: "Invalid email/username or password.")
            }
        } catch {
            print("Error logging in: \(error)")
        }
    }
    
    
    @IBAction func navigateToSignup(_ sender: Any) {
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpView") as! SignUpView
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    
    func showSuccessMessage(on viewController: UIViewController, title: String, message: String,user: User) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Retrieve and save current location to Realm
            if let currentLocation = self.locationManager.location {
                self.saveLocationToRealm(location: currentLocation, forUser: user)
                self.navigateToLocationListView(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, id: user._id, email: user.email)
            } else {
                print("Error: Current location not available.")
            }
        })
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func saveLocationToRealm(location: CLLocation, forUser user: User) {
        let newLocation = LocationModel()
        newLocation.latitude = location.coordinate.latitude
        newLocation.longitude = location.coordinate.longitude
        newLocation.timestamp = location.timestamp
        newLocation.userId = user._id
        
        do {
            try realm.write {
                realm.add(newLocation)
            }
        } catch {
            print("Error saving location to Realm: \(error)")
        }
    }
    func navigateToLocationListView(latitude: Double, longitude: Double, id: ObjectId,email: String) {
        if let locationListVC = storyboard?.instantiateViewController(withIdentifier: "LocationListView") as? LocationListView {
            locationListVC.latitude = latitude
            locationListVC.longitude = longitude
            locationListVC.id = id
            locationListVC.email = email
            navigationController?.pushViewController(locationListVC, animated: true)
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            print("Location authorization denied or restricted.")
            showAlert(message: "Please enable location services to use this feature.")
        case .notDetermined:
            print("Location authorization not determined.")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.last != nil else {
            print("Failed to get location.")
            showAlert(message: "Failed to retrieve current location.")
            return
        }
       
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
        showAlert(message: "Failed to retrieve current location.")
    }
    
}
