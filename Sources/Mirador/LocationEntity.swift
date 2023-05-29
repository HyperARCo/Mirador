//
//  LocationEntity.swift
//  Mirador
//
//  Created by Andrew Hart on 22/05/2023.
//

import Foundation
import RealityKit

public class LocationEntity: Entity {
    public var location: Location
    
    public init(location: Location) {
        self.location = location
        
        super.init()
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
}

public class LocationAnchorEntity: Entity {
    public let locationAnchor: LocationAnchor
    public var referenceImageName: String?
    var kalmanFilter: KalmanFilter?
    
    public init(locationAnchor: LocationAnchor, referenceImageName: String? = nil) {
        self.locationAnchor = locationAnchor
        self.referenceImageName = referenceImageName
        
        super.init()
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
}
