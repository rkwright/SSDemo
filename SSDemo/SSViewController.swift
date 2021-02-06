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
    // Just set up our scene - trivial for the momennt
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
    
    //
    // Create the planet, given its size and an image to use
    //
    func createPlanet(orbitSize: Float, radius: Float, image: String, xPos: Float) -> SCNNode{
        let planetGeom = SCNSphere(radius: CGFloat(radius))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "\(image).jpg")
        planetGeom.materials = [material]

        let planet = SCNNode(geometry: planetGeom)
        // Use the image name as a label - fragile!
        planet.name = image
        planet.position = SCNVector3(x: orbitSize, y: 0, z: 0)
         
         return planet
     }
    
    //
    // Create the specified torus which serves as the "orbit", which
    // in fact owns the planet...  :-)
    //
    func createOrbit ( orbitSize: Float ) -> SCNNode {
            
        let orbit = SCNTorus(ringRadius: CGFloat(orbitSize), pipeRadius: 0.008)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.darkGray
            
        orbit.materials = [material]
            
        let orbitNode = SCNNode(geometry: orbit)
            
        return orbitNode
    }

    //
    //
    //
    func rotateObject ( obj: SCNNode, rotation: Float, duration: Float ) {
        
        let rotation = SCNAction.rotateBy(x:0,y:CGFloat(rotation),z:0, duration: TimeInterval(duration))
        obj.runAction(SCNAction.repeatForever(rotation))
    }
  
    //------------------------- App-specific ---------------------

    //
    //
    //
    func createSolarSystem () {
        // add in the Sun
        let sun = createPlanet(orbitSize: 0.0, radius: 0.8, image: "sun", xPos:0.0)
        rotateObject(obj: sun, rotation: -0.3, duration: 1)
        scnScene.rootNode.addChildNode(sun)

        // then Mercury
        let mercuryOrbit = createOrbit(orbitSize: 1.9)
        let mercury = createPlanet(orbitSize:1.9, radius: 0.3, image: "mercury", xPos:1.9)
        rotateObject(obj: mercury, rotation: 0.6, duration: 0.4)
        rotateObject(obj: mercuryOrbit, rotation: 0.6,  duration: 1)

        mercuryOrbit.addChildNode(mercury)
        scnScene.rootNode.addChildNode(mercuryOrbit)
    }
    
}   // end of class

//-------------- Extensions --------------
//
// Extension protocol so we can handle the render loop calls
//
extension SSViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
}

