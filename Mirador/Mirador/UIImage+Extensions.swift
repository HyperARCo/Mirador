//
//  UIImage+Extensions.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import Foundation
import UIKit
import Metal

extension UIImage {
    func transparencyImage() -> UIImage? {
        guard let inputCGImage = self.cgImage else {
            return nil
        }

        let ciImage = CIImage(cgImage: inputCGImage)
        
        let kernelString = """
        kernel vec4 transparentToBlackWhite(__sample s) {
            float alpha = s.a;
            vec4 white = vec4(1.0, 1.0, 1.0, 1.0);
            vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
            return mix(black, white, alpha);
        }
        """
        
        guard let kernel = CIColorKernel(source: kernelString) else {
            print("Failed to create CIColorKernel")
            return nil
        }

        guard let outputCIImage = kernel.apply(extent: ciImage.extent, arguments: [ciImage]) else {
            print("Failed to apply kernel")
            return nil
        }

        let context = CIContext(options: nil)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return nil
        }

        return UIImage(cgImage: outputCGImage)
    }
    
    func opaque(color: UIColor) -> UIImage? {
        let size = self.size
        let scale = self.scale
        let rect = CGRect(origin: CGPoint.zero, size: size)

        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        // Draw an opaque black background
        context.setFillColor(color.cgColor)
        context.fill(rect)

        // Draw the original image on top of the black background
        self.draw(in: rect)

        guard let outputImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()

        return outputImage
    }
}
