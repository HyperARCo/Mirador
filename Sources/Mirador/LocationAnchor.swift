//
//  LocationEntity.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import Foundation

public class PointOfInterest {
    let name: String
    let location: Location
    
    public init(name: String, location: Location) {
        self.name = name
        self.location = location
    }
}

public enum AnchorOrientation: String, Codable {
    case horizontal = "horizontal"
    case vertical = "vertical"
}

public class LocationAnchor {
    public let name: String
    public let physicalWidth: Double
    public let location: Location
    public let bearing: Float
    public var pointsOfInterest = [PointOfInterest]()
    public let orientation: AnchorOrientation
    
    public init(name: String, physicalWidth: Double, location: Location, bearing: Float, orientation: AnchorOrientation) {
        self.name = name
        self.physicalWidth = physicalWidth
        self.location = location
        self.bearing = bearing
        self.orientation = orientation
    }
}
