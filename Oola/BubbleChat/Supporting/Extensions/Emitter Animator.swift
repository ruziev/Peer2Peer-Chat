

import UIKit
import Foundation

struct EmitterConfig {
    var layer: CAEmitterLayer = CAEmitterLayer()
    var cell: CAEmitterCell = CAEmitterCell()
    var image: UIImage!
    unowned var view: UIView
    
    init(image: UIImage, view: UIView) {
        self.image = image
        self.view = view
    }
}

class Emitter {
    private var emitterConfig: EmitterConfig
    
    init(image: UIImage, view: UIView) {
        self.emitterConfig = EmitterConfig(image: image, view: view)
        
        setUpEmitterLayer()
        setUpEmitterCell()
        
        emitterConfig.layer.emitterCells = [emitterConfig.cell]
        emitterConfig.view.layer.addSublayer(emitterConfig.layer)
    }
    
    private func setUpEmitterLayer() {
        emitterConfig.layer.frame = emitterConfig.view.bounds
        emitterConfig.layer.seed = 128
        emitterConfig.layer.renderMode = kCAEmitterLayerAdditive
        emitterConfig.layer.drawsAsynchronously = true
        
        emitterConfig.layer.birthRate = 0.0
    }
    
    private func setUpEmitterCell() {
        emitterConfig.cell.contents = emitterConfig.image.cgImage
        
        emitterConfig.cell.velocity = 100.0
        emitterConfig.cell.velocityRange = 100.0
        
        emitterConfig.cell.scale = 0.2
        emitterConfig.cell.scaleSpeed = -0.05
        emitterConfig.cell.alphaRange = 0.0
        emitterConfig.cell.alphaSpeed = -0.4
        
        let zeroDegreesInRadians = degreesToRadians(0.0)
        emitterConfig.cell.spin = degreesToRadians(180.0)
        emitterConfig.cell.spinRange = zeroDegreesInRadians
        emitterConfig.cell.emissionRange = degreesToRadians(360.0)
        
        emitterConfig.cell.lifetime = 2.0
        emitterConfig.cell.birthRate = 5.0
        emitterConfig.cell.xAcceleration = 0.0
        emitterConfig.cell.yAcceleration = 200.0
    }
    
    func setUpGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(updateParticlesAnimation(recognizer:)))
        gestureRecognizer.minimumPressDuration = 0.1
        emitterConfig.view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func updateParticlesAnimation(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            emitterConfig.layer.emitterPosition = recognizer.location(in: emitterConfig.view)
            emitterConfig.layer.birthRate = 1.0
        case .changed:
            emitterConfig.layer.emitterPosition = recognizer.location(in: emitterConfig.view)
        case .ended:
            emitterConfig.layer.birthRate = 0
        default:
            break
        }
    }
    
    private func degreesToRadians(_ degrees: Double) -> CGFloat {
        return CGFloat(degrees * Double.pi / 180.0)
    }
}
