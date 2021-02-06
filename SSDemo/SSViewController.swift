//
//  ViewController.swift
//  SSDemo
//
//  Created by rkwright on 2/4/21.
//

import UIKit
import SceneKit

struct PlanetParms {
    let orbitSize : Float
    let diameter  : Float
    let name      : String
}

class SSViewController: UIViewController {
    var scnView     : SCNView!
    var scnScene    : SCNScene!
    var cameraNode  : SCNNode!
    var planets     = [PlanetParms]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupPlanets()
        
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
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 50)
        
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    //--------------- Object Configs ---------------------
    
    //
    // Create the planet, given its size and an image to use
    //
    func createPlanet(orbitSize: Float, radius: Float, image: String) -> SCNNode{
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
            
        let orbit = SCNTorus(ringRadius: CGFloat(orbitSize), pipeRadius: 0.015)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.darkGray
            
        orbit.materials = [material]
            
        let orbitNode = SCNNode(geometry: orbit)
            
        return orbitNode
    }

    //
    // Set up an Action for the supplied object
    //
    func rotateObject ( obj: SCNNode, rotation: Float, duration: Float ) {
        
        let rotation = SCNAction.rotateBy(x:0,y:CGFloat(rotation),z:0, duration: TimeInterval(duration))
        obj.runAction(SCNAction.repeatForever(rotation))
    }
  
    //------------------------- App-specific ---------------------

    //
    //
    //
    func setupPlanets () {
       
        planets.append(PlanetParms(orbitSize: 0.0, diameter: 0.8, name: "Sun"))
        planets.append(PlanetParms(orbitSize: 0.6, diameter: 0.3, name: "Mercury"))
        planets.append(PlanetParms(orbitSize: 0.0, diameter: 0.5, name: "Venus"))
    }
    
    //
    // Walk through the table (TODO) and instantiate the celestial objects
    //
    func createSolarSystem () {
        
        // add in the Sun
        let sun = createPlanet(orbitSize: 0.0, radius: 0.8, image: "sun")
        rotateObject(obj: sun, rotation: -0.3, duration: 1)
        scnScene.rootNode.addChildNode(sun)

        // then Mercury
        let mercuryOrbit = createOrbit(orbitSize: 1.9)
        let mercury = createPlanet(orbitSize:1.9, radius: 0.3, image: "mercury")
        rotateObject(obj: mercury, rotation: 0.6, duration: 0.4)
        rotateObject(obj: mercuryOrbit, rotation: 0.6,  duration: 1)
        mercuryOrbit.addChildNode(mercury)
        scnScene.rootNode.addChildNode(mercuryOrbit)
        
        // then Venus
        let venusOrbit = createOrbit(orbitSize: 3.5)
        let venus = createPlanet(orbitSize:3.5, radius: 0.3, image: "venus")
        rotateObject(obj: venus, rotation: 0.6, duration: 0.4)
        rotateObject(obj: venusOrbit, rotation: 0.6,  duration: 1)
        venusOrbit.addChildNode(venus)
        scnScene.rootNode.addChildNode(venusOrbit)
        
        // then Venus
        let marsOrbit = createOrbit(orbitSize: 4.0)
        let mars = createPlanet(orbitSize:4.0, radius: 0.3, image: "mars")
        rotateObject(obj: mars, rotation: 0.6, duration: 0.4)
        rotateObject(obj: marsOrbit, rotation: 0.6,  duration: 1)
        marsOrbit.addChildNode(venus)
        scnScene.rootNode.addChildNode(marsOrbit)
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

