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
        
        createSolarSystem()
    }

    //-------------- Environment Setup ----------------------------
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
    // Just set up our scene
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
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 20)
        
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    //--------------- Object Configs ---------------------
    func addBox() -> SCNNode {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
      
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        box.materials = [material]

        let boxNode = SCNNode( geometry: box)
        
        boxNode.position = SCNVector3(0, 0, 6)
        
        return boxNode
    }
    
    //
    // Create the planet, given its size and an image to use
    //
    func createPlanet(radius: Float, image: String) -> SCNNode{
          let planet = SCNSphere(radius: CGFloat(radius))
        
          let material = SCNMaterial()
          material.diffuse.contents = UIImage(named: "\(image).jpg")
          planet.materials = [material]

          let planetNode = SCNNode(geometry: planet)
         
         return planetNode
     }
    
    //
    //
    //
    func rotateObject(rotation: Float, planet: SCNNode, duration: Float){
        let rotation = SCNAction.rotateBy(x:0,y:CGFloat(rotation),z:0, duration: TimeInterval(duration))
        planet.runAction(SCNAction.repeatForever(rotation))
    }
        
    //
    // Create the specified torus which serves as the "orbit", which
    // in fact owns the planet...  :-)
    //
    func createOrbit(orbitSize: Float) -> SCNNode {
            
        let orbit = SCNTorus(ringRadius: CGFloat(orbitSize), pipeRadius: 0.002)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.darkGray
            
        orbit.materials = [material]
            
        let orbitNode = SCNNode(geometry: orbit)
            
        return orbitNode
    }

    //---stem---------------------- App-specific ---------------------

    //
    //
    //
    func createSolarSystem () {
        // add in the Sun
        let sun = createPlanet(radius: 0.8, image: "sun")
        sun.name = "sun"
        sun.position = SCNVector3(x:0, y:6, z:0)
        rotateObject(rotation: -0.3, planet: sun, duration: 1)
        scnScene.rootNode.addChildNode(sun)

        // then Mercury
        let mercuryOrbit = createOrbit(orbitSize: 1.9)
        let mercury = createPlanet(radius: 0.3, image: "mercury")
        mercury.name = "mercury"
        mercury.position = SCNVector3(x: 1.9 ,y: 0.6, z: 0)
        rotateObject(rotation: 0.6, planet: mercury, duration: 0.4)
        rotateObject(rotation: 0.6, planet: mercuryOrbit, duration: 1)

        mercuryOrbit.addChildNode(mercury)
        scnScene.rootNode.addChildNode(mercuryOrbit)
        
        let box = addBox()
        scnScene.rootNode.addChildNode(box)

    }
    
}   // end of class



//
// Extension protocol so we can handle the render loop calls
//
extension SSViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        
        
    }
}

