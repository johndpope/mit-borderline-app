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
            
            configuration.maximumNumberOfTrackedImages = 1
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
            let videoUrl = Bundle.main.url(forResource: imageAnchor.referenceImage.name, withExtension: "mp4")!
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
            
            let videoScene = SKScene(size: resolutionForLocalVideo(url: videoUrl)!)
            
            videoNode.position = CGPoint(x: videoScene.size.width/2, y: videoScene.size.height/2) // centers video
            videoNode.yScale = -1.0 // flips video to correct orientation
            
            videoScene.addChild(videoNode)
            
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
    
    // This callback will restart the video when it has reach its end
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero)
        }
    }
    
}

extension ViewController: SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
    }
}

