//
//  ViewController.swift
//  SSDemo
//
//  Created by rkwright on 2/4/21.
//

import UIKit
import SceneKit

struct PlanetParm {
    let orbitRadius : Float     // radius of the orbit
    let diameter    : Float     // diameter of the celestial body
    let name        : String    // name of celestial body as well as the root of the image name
}

class SSViewController: UIViewController {
    var scnView     : SCNView!
    var scnScene    : SCNScene!
    var cameraNode  : SCNNode!
    var planets     = [PlanetParm]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupPlanets()
        
        setupView()
        setupScene()
        setupCamera()
        
        createSolarSystem()
        
        ShapeUtil.drawAxes(scene: scnScene, height: 50)
        // ShapeUtil.linesTest(scene: scnScene)
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
        cameraNode.position = SCNVector3(x: 0, y: 8, z: 24)
        
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    //--------------- Object Configs ---------------------
    
    //
    // Create the planet, given its size and an image to use
    //
    // func createPlanet(orbitSize: Float, radius: Float, image: String) -> SCNNode{
    func createPlanet( parms : PlanetParm ) -> SCNNode{
        let planetGeom = SCNSphere(radius: CGFloat(parms.diameter)/2.0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "\(parms.name).jpg")
        planetGeom.materials = [material]

        let planet = SCNNode(geometry: planetGeom)
        // Use the image name as a label - fragile!
        planet.name = parms.name
        planet.position = SCNVector3(x: parms.orbitRadius, y: 0, z: 0)
         
        return planet
     }
    
    //
    // Create the specified torus which serves as the "orbit", which
    // in fact owns the planet...  :-)
    //
    func createOrbit ( orbitRadius: Float ) -> SCNNode {
            
        let orbit = SCNTorus(ringRadius: CGFloat(orbitRadius), pipeRadius: 0.015)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.darkGray
            
        orbit.materials = [material]
            
        let orbitNode = SCNNode(geometry: orbit)
        //orbitNode.position = SCNVector3(x: orbitRadius, y: 0, z: 0)

        return orbitNode
    }

    
    //
    //
    //
    func setupPlanets () {
       
        planets.append(PlanetParm(orbitRadius: 0.0, diameter: 0.8, name: "sun"))
        planets.append(PlanetParm(orbitRadius: 1.9, diameter: 0.3, name: "mercury"))
        planets.append(PlanetParm(orbitRadius: 3.5, diameter: 0.5, name: "venus"))
        planets.append(PlanetParm(orbitRadius: 4.0, diameter: 0.5, name: "mars"))
    }
    
    //
    // Walk through the table (TODO) and instantiate the celestial objects
    //
    func createSolarSystem () {
        
        // add in the Sun
        let sun = createPlanet(parms: planets[0])
        ShapeUtil.rotateObject(obj: sun, rotation: -0.3, duration: 1)
        scnScene.rootNode.addChildNode(sun)

        // then Mercury
        let mercuryOrbit = createOrbit(orbitRadius: 1.9)
        let mercury = createPlanet(parms: planets[1])
        ShapeUtil.rotateObject(obj: mercury, rotation: 0.6, duration: 0.4)
        ShapeUtil.rotateObject(obj: mercuryOrbit, rotation: 0.6,  duration: 1)
        mercuryOrbit.addChildNode(mercury)
        scnScene.rootNode.addChildNode(mercuryOrbit)
        
        // then Venus
        let venusOrbit = createOrbit(orbitRadius: 3.5)
        let venus = createPlanet(parms: planets[2])
        ShapeUtil.rotateObject(obj: venus, rotation: 0.6, duration: 0.4)
        ShapeUtil.rotateObject(obj: venusOrbit, rotation: 0.6,  duration: 1)
        venusOrbit.addChildNode(venus)
        scnScene.rootNode.addChildNode(venusOrbit)
        
        // then Mars
        let marsOrbit = createOrbit(orbitRadius: 4.0)
        let mars = createPlanet(parms: planets[3])
        ShapeUtil.rotateObject(obj: mars, rotation: 0.6, duration: 0.4)
        ShapeUtil.rotateObject(obj: marsOrbit, rotation: 0.6,  duration: 1)
        marsOrbit.addChildNode(mars)
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

