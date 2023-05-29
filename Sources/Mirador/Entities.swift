//
//  Entities.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import Foundation
import RealityKit

public protocol HasScreenScale : Entity {
}

public class ScreenScaleEntity : Entity, HasScreenScale {
    
}

public protocol HasFaceCamera: Entity {
}

public class FaceCameraEntity: Entity, HasFaceCamera {
    
}
