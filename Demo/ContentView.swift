//
//  ContentView.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import SwiftUI

struct ContentView: View {
    static func locationAnchor() -> LocationAnchor {
        let anchorLocation = Location(coordinate: Coordinate(latitude: 51.47787836, longitude: -0.00084588), altitude: 46)
        let locationAnchor = LocationAnchor(
            name: "greenwich",
            physicalWidth: 0.5,
            location: anchorLocation,
            bearing: Float(-30).degreesToRadians,
            orientation: .horizontal)
        
        let canaryWharfCoordinate = Coordinate(latitude: 51.50493780, longitude: -0.01948017)
        let canaryWharfLocation = Location(coordinate: canaryWharfCoordinate, altitude: 50)
        let canaryWharfPOI = PointOfInterest(name: "Canary Wharf", location: canaryWharfLocation)
        locationAnchor.pointsOfInterest.append(canaryWharfPOI)
        
        let o2Coordinate = Coordinate(latitude: 51.50296112, longitude: 0.00321850)
        let o2Location = Location(coordinate: o2Coordinate, altitude: 50)
        let o2POI = PointOfInterest(name: "O2 Arena", location: o2Location)
        locationAnchor.pointsOfInterest.append(o2POI)
        
        return locationAnchor
    }
    
    static func miradorViewContainer() -> MiradorViewContainer {
        let locationAnchor = ContentView.locationAnchor()
        let viewContainer = MiradorViewContainer(locationAnchor: locationAnchor)
        
        //Custom element
        let cityCoordinate = Coordinate(latitude:51.51438463, longitude: -0.08024839)
        let cityLocation = Location(coordinate: cityCoordinate, altitude: 200)
        let image = UIImage(named: "skyline")!
        
        viewContainer.miradorView.addPOIImage(location: cityLocation, image: image)
        
        return viewContainer
    }
    
    static func locationAnchorFromJSON() -> LocationAnchor? {
        guard let filePath = Bundle.main.path(forResource: "greenwich", ofType: ".json") else {
            return nil
        }

        return LocationAnchor.anchorFromFile(atPath: filePath)
    }
    
    var body: some View {
        ZStack {
            let miradorViewContainer = ContentView.miradorViewContainer()
            miradorViewContainer
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    miradorViewContainer.miradorView.run()
                }
                .onDisappear {
                    miradorViewContainer.miradorView.pause()
                }
            
//            if let locationAnchor = ContentView.locationAnchorFromJSON() {
//                let miradorViewContainer = MiradorViewContainer(locationAnchor: locationAnchor)
//                miradorViewContainer
//                    .edgesIgnoringSafeArea(.all)
//                    .onAppear {
//                        miradorViewContainer.miradorView.run()
//                    }
//                    .onDisappear {
//                        miradorViewContainer.miradorView.pause()
//                    }
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
