//
//  Entities.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import Foundation
import RealityKit

protocol HasScreenScale : Entity {
}

class ScreenScaleEntity : Entity, HasScreenScale {
    
}

protocol HasFaceCamera: Entity {
}

class FaceCameraEntity: Entity, HasFaceCamera {
    
}
