//
//  ViewController.swift
//  SSDemo
//
//  Created by rkwright on 2/4/21.
//

import UIKit
import SceneKit

class SSViewController: UIViewController {
    var scnView     : SCNView!
    var scnScene    : SCNScene!
    var cameraNode  : SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
        setupScene()
        setupCamera()
        
        // addBox()
        var planet : SCNNode
        planet = createPlanet(radius: 0.2, image: "")
        scnScene.rootNode.addChildNode(planet)
    }

    //
    // Set up the view configuration
    //
    func setupView() {
        scnView = self.view as? SCNView
        
        scnView.showsStatistics = true
        
        scnView.allowsCameraControl = true
        
        scnView.autoenablesDefaultLighting = true
        
        scnView.delegate = self
        
        scnView.isPlaying = true
        
        scnView.allowsCameraControl = true
    }

    //
    // Just set up our scene and add the background png to it
    //
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
    }
    
    //
    // Set up a simple perspective camera
    //
    func setupCamera() {
        cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func addBox() {
        let box = SCNBox(width: 0.00025, height: 0.00025, length: 0.00025, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(0, 0, 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        box.materials = [material]
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(boxNode)
        scnView.scene = scene
    }
}   // end of class

/**
  * Create the planet, given its size and an image to use
  */
  func createPlanet(radius: Float, image: String) -> SCNNode{
        let planet = SCNSphere(radius: CGFloat(radius))
        let material = SCNMaterial()
        //material.diffuse.contents = UIImage(named: "\(image).jpg")
        //planet.materials = [material]
        material.diffuse.contents = UIColor.yellow
        planet.materials = [material]

        let planetNode = SCNNode(geometry: planet)
       
       return planetNode
   }

//
// Extension protocol so we can handle the render loop calls
//
extension SSViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        
        
    }
}

