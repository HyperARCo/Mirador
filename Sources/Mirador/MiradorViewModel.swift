//
//  ARView.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import Foundation
import Combine
import ARKit
import RealityKit

class MiradorViewModel: NSObject {
    var locationAnchor: LocationAnchor!
    var subscriptions = [Cancellable]()
    var screenScaleEntities = [ScreenScaleEntity]()
    var faceCameraEntities = [FaceCameraEntity]()
    var locationAnchorEntities = [LocationAnchorEntity]()
    var imageAnchorEntities = [ARImageAnchor: AnchorEntity]()
    
    init(locationAnchor: LocationAnchor) {
        self.locationAnchor = locationAnchor
        
        super.init()
    }
}
