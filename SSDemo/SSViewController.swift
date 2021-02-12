//
//  ViewController.swift
//  SSDemo
//
//  Created by rkwright on 2/4/21.
//

import UIKit
import SceneKit

struct PlanetParm {
    let name        : String    // name of celestial body as well as the root of the image name
    let orbitRadius : Float     // radius of the orbit
    let diameter    : Float     // diameter of the celestial body
    let yearLength  : Float     // planet's rotational period, in seconds
    let dayLength   : Float     // planet's own rotational period, i.e. daylength
}

class SSViewController: UIViewController {
    var scnView     : SCNView!
    var scnScene    : SCNScene!
    var cameraNode  : SCNNode!
    var planets     = [PlanetParm]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fill out the database
        setupPlanets()
        
        // set up the ScneKit environment
        setupView()
        setupScene()
        setupCamera()
        
        // then fiat lux!
        createSolarSystem()
    }

//-------------- Environment Setup ----------------------------
    
    //
    // Set up the view configuration
    //
    func setupView() {
        scnView = self.view as? SCNView
        scnView.showsStatistics = true
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
        
        self.view.backgroundColor = .black
        
        ShapeUtil.drawAxes(scene: scnScene, height: 50)
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
    
//--------------- Celestial Configs ---------------------
    
    //
    // Create the planet, given its size and an image to use
    //
    func createPlanet( parms : PlanetParm ) {
        
        let planetGeom = SCNSphere(radius: CGFloat(parms.diameter)/2.0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "\(parms.name).jpg")
        planetGeom.materials = [material]

        let planet = SCNNode(geometry: planetGeom)
        
        // Use the image name as a label - fragile!
        planet.name = parms.name
        planet.position = SCNVector3(x: parms.orbitRadius, y: 0, z: 0)
         
        ShapeUtil.rotateObject(obj: planet, rotation: parms.dayLength, duration: 1)

        let orbit = createOrbit(orbitRadius: parms.orbitRadius)
        orbit.addChildNode(planet)
        ShapeUtil.rotateObject(obj: orbit, rotation: parms.yearLength, duration: 1)
        scnScene.rootNode.addChildNode(orbit)
     }
    
    //
    // Create the specified torus which serves as the "orbit", which
    // in fact owns the planet...  :-)
    //
    func createOrbit ( orbitRadius: Float ) -> SCNNode {
            
        let orbit = SCNTorus(ringRadius: CGFloat(orbitRadius), pipeRadius: 0.025)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.specular.contents = UIColor.white

        orbit.materials = [material]
            
        let orbitNode = SCNNode(geometry: orbit)
        //orbitNode.position = SCNVector3(x: orbitRadius, y: 0, z: 0)

        return orbitNode
    }

    //
    // Set up the "database" of planets
    //
    func setupPlanets () {
       
        planets.append( PlanetParm(name: "sun", orbitRadius: 0.01, diameter: 0.8, yearLength: -0.3, dayLength: 1.0 ))
        planets.append( PlanetParm(name: "mercury", orbitRadius: 1.9, diameter: 0.3, yearLength: 1.5, dayLength: 0.6 ))
        planets.append( PlanetParm(name: "venus", orbitRadius: 3.5, diameter: 0.5, yearLength: 0.6, dayLength: 1.5  ))
        planets.append( PlanetParm(name: "mars", orbitRadius: 4.0, diameter: 0.5, yearLength: 0.8, dayLength: 1.5 ))
    }
    
    //
    // Walk through the table (TODO) and instantiate the celestial objects
    //
    func createSolarSystem () {
        
        // add in the Sun, then the rest of the planets
        createPlanet(parms: planets[0])
 
        createPlanet(parms: planets[1])

        createPlanet(parms: planets[2])

        createPlanet(parms: planets[3])
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
