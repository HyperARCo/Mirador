//
//  LocationEntity.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import Foundation

class PointOfInterest {
    let name: String
    let location: Location
    
    init(name: String, location: Location) {
        self.name = name
        self.location = location
    }
}

class LocationAnchor {
    let name: String
    let physicalWidth: Double
    let location: Location
    let bearing: Float
    var pointsOfInterest = [PointOfInterest]()
    
    init(name: String, physicalWidth: Double, location: Location, bearing: Float) {
        self.name = name
        self.physicalWidth = physicalWidth
        self.location = location
        self.bearing = bearing
    }
}
