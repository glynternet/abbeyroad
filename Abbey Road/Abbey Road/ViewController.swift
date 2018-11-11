//
//  ViewController.swift
//  Abbey Road
//
//  Created by Alex Powell on 11/10/18.
//  Copyright © 2018 Nightshade. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MultipeerConnectivity
import PureLayout

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet weak var drumButton: UIButton!
    @IBOutlet weak var harpButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    
    let musicService = MusicService()
    
    var cubeNode: SCNNode?
    var peerNodes = [MCPeerID : SCNNode]()
    
    var instrumentView: UIView?
    
    var instruments = [UIView]()
    //var instruments2Used = [UIView : Bool]()
    
    var lastPositionUpdate: Date!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        musicService.delegate = self
        musicService.startPeer()
        
        
        
//        view.addSubview(backbutton)
//        backbutton.autoPinEdge(toSuperviewEdge: .left)
//        backbutton.autoPinEdge(toSuperviewEdge: .right)
//        backbutton.autoPinEdge(toSuperviewEdge: .top)
//        backbutton.autoSetDimension(.height, toSize: 40)
//        
//        backbutton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
//        
//        self.drumButton.transform = self.drumButton.transform.rotated(by: CGFloat(-1*M_PI_2))
//        self.harpButton.transform = self.harpButton.transform.rotated(by: CGFloat(-1*M_PI_2))
        
//        var div = DrumInstrumentView(forAutoLayout: ())
//        if let div = div as? DrumInstrumentView {
//            div.musicService = musicService
//            view.addSubview(div)
//            div.autoPinEdgesToSuperviewEdges()
//        }
//        instruments.append(div)
        //instruments2Used[div] = false
        
//        var hiv = HarpInstrumentView(forAutoLayout: ())
//        if let hiv = hiv as? HarpInstrumentView {
//            hiv.musicService = musicService
//            view.addSubview(hiv)
//            hiv.autoPinEdgesToSuperviewEdges()
//        }
//        instruments.append(hiv)
        //instruments2Used[hiv] = false
        
        lastPositionUpdate = Date()
    }
    
    @IBAction func backTapped(sender: UIButton!) {
        print("Going back")
        sender.removeFromSuperview()
        instrumentView?.removeFromSuperview()
        instrumentView = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
        configuration.detectionImages = referenceImages

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        print("Marker detected")
        let node = SCNNode()
        node.geometry = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
        node.pivot = SCNMatrix4MakeTranslation(0, -0.005, 0)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        cubeNode = node
        sceneView.session.setWorldOrigin(relativeTransform: anchor.transform)
        
        return node
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let newDate = Date()
        if newDate.timeIntervalSince(lastPositionUpdate) >= 0.04 {
            let x = frame.camera.transform.columns.3.x
            let y = frame.camera.transform.columns.3.y
            let z = frame.camera.transform.columns.3.z
            musicService.send(position: simd_float3(x, y, z))
            lastPositionUpdate = newDate
        }
    }
    
    // MARK: - Color and actions
    
    func change(color: UIColor) {
        if let node = cubeNode {
            node.geometry?.firstMaterial?.diffuse.contents = color
        }
    }
    
    @IBAction func redTapped() {
        change(color: .red)
        musicService.send(colorName: "red")
        
        
//        if instruments.count > 0 {
//            var instrument = instruments.remove(at: 0)
//
//        }
        
        
        instrumentView = DrumInstrumentView(forAutoLayout: ())
        if let instrumentView = instrumentView as? DrumInstrumentView {
            instrumentView.musicService = musicService
            view.addSubview(instrumentView)
            instrumentView.autoPinEdgesToSuperviewEdges()
        }
        
        let backbutton = UIButton(forAutoLayout: ())
        backbutton.setTitle("X", for: .normal)
        view.addSubview(backbutton)
        backbutton.autoPinEdge(toSuperviewEdge: .left)
        backbutton.autoPinEdge(toSuperviewEdge: .top)
        
        backbutton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    @IBAction func greenTapped() {
        change(color: .green)
        musicService.send(colorName: "green")
        
        instrumentView = HarpInstrumentView(forAutoLayout: ())
        if let instrumentView = instrumentView as? HarpInstrumentView {
            instrumentView.musicService = musicService
            view.addSubview(instrumentView)
            instrumentView.autoPinEdgesToSuperviewEdges()
        }
        
        let backbutton = UIButton(forAutoLayout: ())
        backbutton.setTitle("X", for: .normal)
        view.addSubview(backbutton)
        backbutton.autoPinEdge(toSuperviewEdge: .left)
        backbutton.autoPinEdge(toSuperviewEdge: .top)
        
        backbutton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
}

extension ViewController: MusicServiceDelegate {
    
    func connectedDevicesChanged(service: MusicService, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
//            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func colorChanged(service: MusicService, peerId: MCPeerID, colorString: String) {
        OperationQueue.main.addOperation {
            switch colorString {
            case "red":
                self.change(color: .red)
            case "green":
                self.change(color: .green)
            default:
                NSLog("%@", "Unknown color value received: \(colorString)")
            }
        }
    }
    
    func positionChanged(service: MusicService, peerId: MCPeerID, position: simd_float3) {
        if peerNodes[peerId] == nil {
            let node = SCNNode()
            node.geometry = SCNSphere(radius: 0.05)
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            sceneView.scene.rootNode.addChildNode(node)
            peerNodes[peerId] = node
        }
        
        let peerNode = peerNodes[peerId]!
        peerNode.position = SCNVector3(position)
    }
    
}
