//
//  Anchor+JSON.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import Foundation

struct AnchorData: Codable {
    let name: String
    let physical_width: Double
    let coordinate: [Double]
    let altitude: Double
    let bearing_degrees: Float
    let orientation: AnchorOrientation
}

struct PointOfInterestData: Codable {
    let name: String
    let coordinate: [Double]
    let altitude: Double
}

struct GeoJSONData: Codable {
    let anchor: AnchorData
    let points_of_interest: [PointOfInterestData]
}

extension LocationAnchor {
    static func anchorFromJSONData(jsonData: Data) -> LocationAnchor? {
        let decoder = JSONDecoder()

        do {
            let geoJSONData = try decoder.decode(GeoJSONData.self, from: jsonData)
            
            let anchorCoordinate = Coordinate(latitude: geoJSONData.anchor.coordinate[1], longitude: geoJSONData.anchor.coordinate[0])
            let anchorLocation = Location(coordinate: anchorCoordinate, altitude: geoJSONData.anchor.altitude)
            let anchor = LocationAnchor(name: geoJSONData.anchor.name, physicalWidth: geoJSONData.anchor.physical_width, location: anchorLocation, bearing: geoJSONData.anchor.bearing_degrees.degreesToRadians, orientation: geoJSONData.anchor.orientation)
            
            for poiData in geoJSONData.points_of_interest {
                let poiCoordinate = Coordinate(latitude: poiData.coordinate[1], longitude: poiData.coordinate[0])
                let poiLocation = Location(coordinate: poiCoordinate, altitude: poiData.altitude)
                let pointOfInterest = PointOfInterest(name: poiData.name, location: poiLocation)
                anchor.pointsOfInterest.append(pointOfInterest)
            }
            
            return anchor
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    static func anchorFromFile(atPath path: String) -> LocationAnchor? {
        guard let jsonData = readDataFromFile(atPath: path) else {
            return nil
        }
        
        return anchorFromJSONData(jsonData: jsonData)
    }
}

func readDataFromFile(atPath path: String) -> Data? {
    let fileURL = URL(fileURLWithPath: path)

    do {
        let data = try Data(contentsOf: fileURL)
        return data
    } catch {
        print("Error reading data from file: \(error.localizedDescription)")
        return nil
    }
}
