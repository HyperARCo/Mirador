//
//  RKExtensions.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import Foundation
import RealityKit

extension SIMD3 where Scalar == Float {
    func distance(to other: SIMD3<Float>) -> Float {
        return sqrt(pow(self.x - other.x, 2) + pow(self.y - other.y, 2) + pow(self.z - other.z, 2))
    }
}

extension simd_float4x4 {
    var eulerAngles: simd_float3 {
        simd_float3(
            x: asin(-self[2][1]),
            y: atan2(self[2][0], self[2][2]),
            z: atan2(self[0][1], self[1][1])
        )
    }
}
