//
//  LocationEntity.swift
//  Mirador
//
//  Created by Andrew Hart on 22/05/2023.
//

import Foundation
import RealityKit

class LocationEntity: Entity {
    var location: Location
    
    init(location: Location) {
        self.location = location
        
        super.init()
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
}

class LocationAnchorEntity: Entity {
    let locationAnchor: LocationAnchor
    var referenceImageName: String?
    var kalmanFilter: KalmanFilter?
    
    init(locationAnchor: LocationAnchor, referenceImageName: String? = nil) {
        self.locationAnchor = locationAnchor
        self.referenceImageName = referenceImageName
        
        super.init()
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
}
