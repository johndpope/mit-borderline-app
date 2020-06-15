//
//  ViewController.swift
//  mit-borderline-app
//
//  Created by Elaine Xiao on 6/1/20.
//  Copyright © 2020 Elaine Xiao. All rights reserved.
//

import UIKit
import SwiftyGif
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    let logoAnimationView = LogoAnimationView()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(logoAnimationView)
        logoAnimationView.pinEdgesToSuperView()
        logoAnimationView.logoGifImageView.delegate = self
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logoAnimationView.logoGifImageView.startAnimatingGif()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "BorderlineImages", bundle: Bundle.main) {
            configuration.trackingImages = trackedImages
            
            configuration.maximumNumberOfTrackedImages = 10 // arbitrary number
        }

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            // Create a video player
            let videoUrl = Bundle.main.url(forResource: "Animations/" + imageAnchor.referenceImage.name!, withExtension: "mp4")!
            let videoPlayer = AVPlayer(url: videoUrl)
            
            // To make the video loop
            videoPlayer.actionAtItemEnd = .none
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(ViewController.playerItemDidReachEnd),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: videoPlayer.currentItem)
            
            let videoNode = SKVideoNode(avPlayer: videoPlayer)
            videoNode.play()
            
            // Initialize videoScene
            let videoScene = SKScene(size: resolutionForLocalVideo(url: videoUrl)!)
            
            // Rescale and center videoNode
            rescaleVideoNode(videoNode: videoNode, sceneWidth: videoScene.size.width, sceneHeight: videoScene.size.height)
            
            // Create effect node to make background transparent
            let effectNode = SKEffectNode()
            effectNode.addChild(videoNode)
            effectNode.filter = colorCubeFilterForChromaKey(hueAngle: 120)
            
            // Add effect node to videoScene
            videoScene.addChild(effectNode)
            
            // Create plane for videoScene
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = videoScene
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)

        }
        return node
    }
    
    // Gets video dimensions used to initialize SKScene in renderer
    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
       let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    // Rescales and centers videoNode
    private func rescaleVideoNode(videoNode: SKVideoNode, sceneWidth: CGFloat, sceneHeight: CGFloat) {
        videoNode.position = CGPoint(x: sceneWidth/2, y: sceneHeight/2) // centers video
        videoNode.yScale = -1.0 // flips video to correct orientation
    }
    
    // This callback will restart the video when it has reach its end
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero)
        }
    }
    
    func RGBtoHSV(r : Float, g : Float, b : Float) -> (h : Float, s : Float, v : Float) {
        var h : CGFloat = 0
        var s : CGFloat = 0
        var v : CGFloat = 0
        let col = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
        col.getHue(&h, saturation: &s, brightness: &v, alpha: nil)
        return (Float(h), Float(s), Float(v))
    }

    func colorCubeFilterForChromaKey(hueAngle: Float) -> CIFilter {

        let hueRange: Float = 20 // degrees size pie shape that we want to replace
        let minHueAngle: Float = (hueAngle - hueRange/2.0) / 360
        let maxHueAngle: Float = (hueAngle + hueRange/2.0) / 360

        let size = 64
        var cubeData = [Float](repeating: 0, count: size * size * size * 4)
        var rgb: [Float] = [0, 0, 0]
        var hsv: (h : Float, s : Float, v : Float)
        var offset = 0

        for z in 0 ..< size {
            rgb[2] = Float(z) / Float(size) // blue value
            for y in 0 ..< size {
                rgb[1] = Float(y) / Float(size) // green value
                for x in 0 ..< size {

                    rgb[0] = Float(x) / Float(size) // red value
                    hsv = RGBtoHSV(r: rgb[0], g: rgb[1], b: rgb[2])
                    // TODO: Check if hsv.s > 0.5 is really nesseccary
                    let alpha: Float = (hsv.h > minHueAngle && hsv.h < maxHueAngle && hsv.s > 0.5) ? 0 : 1.0

                    cubeData[offset] = rgb[0] * alpha
                    cubeData[offset + 1] = rgb[1] * alpha
                    cubeData[offset + 2] = rgb[2] * alpha
                    cubeData[offset + 3] = alpha
                    offset += 4
                }
            }
        }
        let b = cubeData.withUnsafeBufferPointer { Data(buffer: $0) }
        let data = b as NSData

        let colorCube = CIFilter(name: "CIColorCube", parameters: [
            "inputCubeDimension": size,
            "inputCubeData": data
            ])
        return colorCube!
    }
    
    
}

// Hide GIF after it stops playing
extension ViewController: SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
    }
}

