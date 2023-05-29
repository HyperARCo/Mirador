//
//  MiradorView.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import Foundation
import SwiftUI
import RealityKit
import ARKit

public class MiradorView: UIView {
    let model: MiradorViewModel
    
    let arView = ARView()
    
    private var detectionImages = Set<ARReferenceImage>()
    
    public init(locationAnchor: LocationAnchor) {
        self.model = MiradorViewModel(locationAnchor: locationAnchor)
        
        super.init(frame: .zero)
        
        arView.renderOptions = [.disableHDR]
        arView.session.delegate = self
        arView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(arView)
        
        if let anchor = model.locationAnchor,
           let image = UIImage(named: anchor.name),
           let cgImage = image.cgImage {
            let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: anchor.physicalWidth)
            referenceImage.name = anchor.name
            detectionImages.insert(referenceImage)

            for poi in anchor.pointsOfInterest {
                addPOILabel(poi: poi)
            }
        }
        
        let baseAnchor = AnchorEntity(world: [0,0,0])
        arView.scene.addAnchor(baseAnchor)
        
        let sceneEventsSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { event in
            guard let currentFrame = self.arView.session.currentFrame else { return }

            let imageResolution = currentFrame.camera.imageResolution
            let intrinsics = currentFrame.camera.intrinsics
            //        let xFOV = 2 * atan(Float(imageResolution.width)/(2 * intrinsics[0,0]))
            var yFOV = 2 * atan(Float(imageResolution.height)/(2 * intrinsics[1,1]))

            let visibleYFOVScale = min(
                1,
                (self.arView.frame.size.width / self.arView.frame.size.height) /
                    (imageResolution.height / imageResolution.width))

            yFOV *= Float(visibleYFOVScale)

            let A = yFOV * 0.5
            let B = Float(180).degreesToRadians - A - Float(90).degreesToRadians
            let a = (sin(A) * 1) / sin(B)

            //Visible distance, at a distance from the camera of 1m
            let horizontalVisibleDistance = a * 2

            //Could be 2m of width visible 1m away
            //With 375 points, that's 0.005333333.
            let horizontalDistancePerPointAt1m = horizontalVisibleDistance / Float(self.arView.frame.size.width)
            
            for entity in self.model.screenScaleEntities {
                let entityPosition = entity.position(relativeTo: nil)
                let distance = self.arView.cameraTransform.translation.distance(to: entityPosition)

                let distancePerPoint = horizontalDistancePerPointAt1m * distance
                let scale = distancePerPoint

                entity.scale = [scale, scale, scale]
            }

            for entity in self.model.faceCameraEntities {
                entity.look(at: self.arView.cameraTransform.translation, from: entity.position(relativeTo: nil), relativeTo: nil)
            }
            
            let childLocationEntities = self.model.locationAnchorEntity.children.filter({$0 is LocationEntity}) as! [LocationEntity]
            
            for locationEntity in childLocationEntities {
                var relativePoint = self.model.locationAnchor.location.coordinate.relativePoint(of: locationEntity.location.coordinate)
                let distance = CGPoint.zero.distance(to: relativePoint)
                let bearing = CGPoint.zero.bearing(to: relativePoint)
                
                var y = Float(locationEntity.location.altitude - self.model.locationAnchor.location.altitude)
                
                //Elements further than 1000m don't render within RealityKit
                //So, to be safe, anything with a distance further than 250m, we squash the distance to be within 250-500m
                //We may want to limit this to content which has scale applied
                
                // Check if the distance is greater than 250m
                if distance > 250 {
                    // Define a scaling factor that maps the distance to the range [250, 500]
                    let maxScaledDistance: CGFloat = 500
                    let minScaledDistance: CGFloat = 250
                    let scaleFactor: CGFloat = (maxScaledDistance - minScaledDistance) / log10(distance - minScaledDistance + 1)
                    
                    // Calculate the squashed distance
                    let squashedDistance = minScaledDistance + log10(distance - minScaledDistance + 1) * scaleFactor
                    
                    // Calculate the new relative point using the squashed distance and bearing
                    relativePoint = CGPoint.zero.destination(bearing: bearing, distance: squashedDistance)
                    
                    let squashFactor = squashedDistance / distance
                    y *= Float(squashFactor)
                }
                
                locationEntity.position = [
                    Float(relativePoint.x),
                    y,
                    Float(-relativePoint.y)]
            }
        }

        model.subscriptions.append(sceneEventsSubscription)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Call when the app is active and in the foreground
    public func run() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.detectionImages = detectionImages
        configuration.maximumNumberOfTrackedImages = 1
        
        arView.session.run(configuration)
    }
    
    ///Call when the app leaves the foreground
    public func pause() {
        arView.session.pause()
        
        model.locationAnchorEntity.kalmanFilter = nil
    }
    
    func setupRealityKitPlane(with image: UIImage, spokeAdditionalHeight: Float = 0, cornerRadius: Float) -> Entity {
        let opaque = image.opaque(color: UIColor(white: 0.5, alpha: 1.0))!
        
        let textureResource = try! TextureResource.generate(
            from: opaque.cgImage!, options: .init(semantic: .none))
        
        let texture = MaterialParameters.Texture(textureResource)
        
        let transparentImage = image.transparencyImage()!
        let transparentTextureResource = try! TextureResource.generate(
            from: transparentImage.cgImage!, options: .init(semantic: .none))
        let transparentTexture = MaterialParameters.Texture(transparentTextureResource)
        
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .clear)
        material.emissiveColor = .init(color: .clear, texture: texture)
        material.emissiveIntensity = 2
        material.blending = .transparent(opacity: .init(texture: transparentTexture))
        material.opacityThreshold = 0
        
        let plane = MeshResource.generatePlane(width: Float(image.size.width), depth: Float(image.size.height), cornerRadius: 0)
        
        let model = ModelEntity(mesh: plane, materials: [material])
        
        let rotationAngle = Float.pi / 2
        model.transform.rotation = simd_quatf(angle: rotationAngle, axis: [1, 0, 0])
        
        let spokeHeight: Float = 60
        model.position.y += spokeHeight + Float(image.size.height * 0.5)
        
        let parentEntity = Entity()
        parentEntity.addChild(model)
        
        let circle = MeshResource.generatePlane(width: 11, depth: 11, cornerRadius: 5.5)
        let whiteMaterial = UnlitMaterial(color: .white)
        let circleEntity = ModelEntity(mesh: circle, materials: [whiteMaterial])
        circleEntity.transform.rotation = simd_quatf(angle: rotationAngle, axis: [1, 0, 0])
        
        let actualHeight = spokeHeight + spokeAdditionalHeight
        
        let spoke = MeshResource.generatePlane(width: 2, depth: actualHeight)
        let spokeEntity = ModelEntity(mesh: spoke, materials: [whiteMaterial])
        spokeEntity.transform.rotation = simd_quatf(angle: rotationAngle, axis: [1, 0, 0])
        spokeEntity.position.y += (actualHeight * 0.5)
        parentEntity.addChild(circleEntity)
        parentEntity.addChild(spokeEntity)
        
        parentEntity.transform.rotation = simd_quatf(angle: Float.pi, axis: [0, 1, 0])
        
        let containerEntity = Entity()
        containerEntity.addChild(parentEntity)
        
        return containerEntity
    }
    
    func addPOILabel(poi: PointOfInterest, spokeHeight: Float = 60) {
        let cornerRadius: CGFloat = 53
        
        let shadowRadius: CGFloat = 4
        let shadowOffset = CGSize(width: 0, height: 2)
        
        let padding = CGSize(
            width: (shadowRadius * 2) + abs(shadowOffset.width),
            height: (shadowRadius * 2) + abs(shadowOffset.height))
        
        let renderer = ImageRenderer(
            content: Text(poi.name)
                .font(Font.system(size: 14, weight: .semibold))
                .foregroundColor(Color.black)
                .padding(EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14))
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: shadowRadius, x: shadowOffset.width, y: shadowOffset.height)
                )
                .padding([.leading, .trailing], padding.width)
                .padding([.top, .bottom], padding.height)
        )
        
        renderer.isOpaque = false
        renderer.scale = UIScreen.main.scale
        
        guard let image = renderer.uiImage else { return }
        
        addPOIImage(location: poi.location, image: image, spokeAdditionalHeight: Float(padding.height))
    }
    
    ///Adds a POI element displaying an image. Image will appear at screen-scale, at the size given.
    ///e.g. if the image is 60x60, it'll appear at 60x60 points on-sreen.
    ///The image will face the camera and be anchored to the given location.
    ///This supports transparency, dropshadows etc., and displays the image without any special lighting effects.
    ///- Parameters:
    ///    - spokeAdditionalHeight: The spoke is the stem that reaches up from the point of interest to the given image, ending at the bottom of the image. If the bottom of the image is transparent, to allow for a visible shadow, this should specify the extra bottom padding.
    public func addPOIImage(location: Location, image: UIImage, spokeAdditionalHeight: Float = 0) {
        let entity = setupRealityKitPlane(
            with: image,
            spokeAdditionalHeight: spokeAdditionalHeight,
            cornerRadius: Float(image.size.height * 0.5))

        addPOIEntity(location: location, entity: entity)
    }
    
    ///Adds a POI entity, which will appear at screen-scale at the size given.
    ///e.g. if the entity is 40m wide, it'll appear as 40 points on-screen.
    ///The entity will face the camera and be anchored to the given location.
    public func addPOIEntity(location: Location, entity: Entity) {
        let screenScaleEntity = ScreenScaleEntity()
        screenScaleEntity.addChild(entity)
        model.screenScaleEntities.append(screenScaleEntity)

        let faceCameraEntity = FaceCameraEntity()
        faceCameraEntity.addChild(screenScaleEntity)
        model.faceCameraEntities.append(faceCameraEntity)
        
        addLocationEntity(location: location, entity: faceCameraEntity)
    }
    
    ///Adds an entity anchored to the given location. This does not come with screen scale or facing the camera - use `addPOIEntity` for that functionality.
    public func addLocationEntity(location: Location, entity: Entity) {
        let locationEntity = LocationEntity(location: location)
        locationEntity.addChild(entity)
        
        model.locationAnchorEntity.addChild(locationEntity)
    }
    
    func updateOrientation(imageAnchor: ARImageAnchor, anchorEntity: AnchorEntity) {
        anchorEntity.setTransformMatrix(imageAnchor.transform, relativeTo: nil)
        
        let angle: Float
        
        if model.locationAnchorEntity.locationAnchor.orientation == .horizontal {
            angle = imageAnchor.transform.eulerAngles.y + model.locationAnchorEntity.locationAnchor.bearing
            model.locationAnchorEntity.setOrientation(simd_quatf(angle: angle, axis: [0,1,0]), relativeTo: nil)
        } else {
            let rotationMatrix = simd_float4x4(SCNMatrix4MakeRotation(Float(-90).degreesToRadians, 1, 0, 0))
            let transform = imageAnchor.transform * rotationMatrix
            
            angle = transform.eulerAngles.y + model.locationAnchorEntity.locationAnchor.bearing
        }
        
        if let kalmanFilter = model.locationAnchorEntity.kalmanFilter {
            kalmanFilter.update(measurement: angle, measurementUncertainty: Float(1).degreesToRadians)
        } else {
            let kalmanFilter = KalmanFilter(initialEstimate: angle, initialUncertainty:  Float(1).degreesToRadians)
            model.locationAnchorEntity.kalmanFilter = kalmanFilter
        }
        
        guard let angleEstimate = model.locationAnchorEntity.kalmanFilter?.getEstimate() else { return }
       
        model.locationAnchorEntity.setOrientation(simd_quatf(angle: angleEstimate, axis: [0,1,0]), relativeTo: nil)
    }
}

extension MiradorView: ARSessionDelegate {
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
    }
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                let anchorEntity = AnchorEntity(world: imageAnchor.transform)
                
                model.imageAnchorEntities[imageAnchor] = anchorEntity
                
                arView.scene.addAnchor(anchorEntity)
                
                let referenceImageName = imageAnchor.referenceImage.name
                
                if let anchorReferenceImageName = model.locationAnchorEntity.referenceImageName, anchorReferenceImageName == referenceImageName {
                    anchorEntity.addChild(model.locationAnchorEntity)
                    
                    updateOrientation(imageAnchor: imageAnchor, anchorEntity: anchorEntity)
                }
            }
        }
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                if let anchorEntity = model.imageAnchorEntities[imageAnchor] {
                    updateOrientation(imageAnchor: imageAnchor, anchorEntity: anchorEntity)
                }
            }
        }
    }
}

public struct MiradorViewContainer: UIViewRepresentable {
    var locationAnchor: LocationAnchor
    public let miradorView: MiradorView
    
    public init(locationAnchor: LocationAnchor) {
        self.locationAnchor = locationAnchor
        miradorView = MiradorView(locationAnchor: self.locationAnchor)
    }
    
    public func makeUIView(context: Context) -> MiradorView {
        return miradorView
    }

    public func updateUIView(_ uiView: MiradorView, context: Context) {}
}
