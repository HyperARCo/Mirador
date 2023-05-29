//
//  Location.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import Foundation
import CoreLocation

public typealias Coordinate = CLLocationCoordinate2D
public typealias Distance = CLLocationDistance

extension Coordinate {
    static let zero = Coordinate()
}

extension Distance {
    static let earthRadius = 6371e3
}

public extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
    
    func circularDifference(to anotherValue: Self) -> Self {
        var difference = anotherValue - self
        
        if difference.radiansToDegrees < -180 {
            difference += Self(360).degreesToRadians
        } else if difference.radiansToDegrees > 180 {
            difference -= Self(360).degreesToRadians
        }
        
        return difference
    }
    
    var circularValue: Self {
        let value = self - (floor(self / Self(360).degreesToRadians) * Self(360).degreesToRadians)
        
        if value < Self(-180).degreesToRadians {
            return value + Self(360).degreesToRadians
        } else if value > Self(180).degreesToRadians {
            return value - Self(360).degreesToRadians
        }
        
        return value
    }
}

extension Coordinate {
    ///Uses the ‘haversine’ formula to calculate
    ///the great-circle distance between two points
    func greatCircleDistance(to coordinate: Coordinate) -> Distance {
        let R = Distance.earthRadius // metres
        let φ1 = self.latitude.degreesToRadians
        let φ2 = coordinate.latitude.degreesToRadians
        let Δφ = (coordinate.latitude-self.latitude).degreesToRadians
        let Δλ = (coordinate.longitude-self.longitude).degreesToRadians
        
        let a = sin(Δφ/2) * sin(Δφ/2) + cos(φ1) * cos(φ2) * sin(Δλ/2) * sin(Δλ/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let distance = R * c
        
        return distance
    }
    
    ///Initial bearing, when travelling between 2 given coordinates around a sphere
    func initialBearing(to coordinate: Coordinate) -> Float {
        let φ1 = self.latitude.degreesToRadians
        let φ2 = coordinate.latitude.degreesToRadians
        
        let λ1 = self.longitude.degreesToRadians
        let λ2 = coordinate.longitude.degreesToRadians
        
        let y = sin(λ2-λ1) * cos(φ2)
        let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(λ2-λ1)
        let bearing = Float(atan2(y, x))
        
        return bearing
    }
    
    ///Destination coordinate given a bearing and distance from a start coordinate
    func destination(bearing: Float, distance: Distance) -> Coordinate {
        let R = Distance.earthRadius
        let d = distance
        let h = Double(bearing)
        
        let φ1 = latitude.degreesToRadians
        let λ1 = longitude.degreesToRadians
        
        let φ2 = asin(sin(φ1) * cos(d/R) + cos(φ1) * sin(d/R) * cos(h))
        let λ2 = λ1 + atan2(sin(h) * sin(d/R) * cos(φ1),
                              cos(d/R) - sin(φ1) * sin(φ2));
        
        return Coordinate(latitude: φ2.radiansToDegrees, longitude: λ2.radiansToDegrees)
    }
    
    func relativePoint(of anotherCoordinate: Coordinate) -> CGPoint {
        let distance = self.greatCircleDistance(to: anotherCoordinate)
        let bearing = self.initialBearing(to: anotherCoordinate)
        
        let x = Float(distance) * sin(bearing)
        let y = Float(distance) * cos(bearing)
        
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

extension CGPoint {
    func bearing(to point: CGPoint) -> CGFloat {
        let bearing = atan2(point.x - self.x, point.y - self.y)
        
        return bearing
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - point.x, 2) + pow(self.y - point.y, 2))
    }
    
    ///Gives destination point, given a bearing and distance
    func destination(bearing: CGFloat, distance: CGFloat) -> CGPoint {
        let x = distance * sin(bearing)
        let y = distance * cos(bearing)
        
        return CGPoint(x: self.x + x, y: self.y + y)
    }
}

public struct Location {
    var coordinate: Coordinate
    var altitude: Distance
    
    public static let zero = Location(coordinate: Coordinate.zero, altitude: 0)
    
    public init(coordinate: Coordinate, altitude: Distance) {
        self.coordinate = coordinate
        self.altitude = altitude
    }
}

