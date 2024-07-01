//
//  userdata.swift
//  UpdatedNewProject
//
//  Created by Nivedha Moorthy on 01/07/24.
//

import RealmSwift
import Foundation

class User: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var username: String = ""
    @Persisted var email: String = ""
    @Persisted var password: String = ""
    @Persisted var confpassword: String = ""

    // Define the relationship to locations
    let locations = List<LocationModel>()
}
class UserSession: Object {
    @objc dynamic var userId = ""
    @objc dynamic var isLoggedIn = false
}
