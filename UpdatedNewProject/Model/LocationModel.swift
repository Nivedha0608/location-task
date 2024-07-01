//
//  LocationModel.swift
//  UpdatedNewProject
//
//  Created by Nivedha Moorthy on 01/07/24.
//

import Foundation
import RealmSwift

class LocationModel: Object {
    @Persisted var latitude: Double = 0.0
    @Persisted var longitude: Double = 0.0
    @Persisted var timestamp: Date = Date()
    @Persisted var userId: ObjectId = ObjectId()
  // Ensure this matches the type of User's primary key

    convenience init(latitude: Double, longitude: Double, timestamp: Date, userId: ObjectId) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.userId = userId
    }
}

