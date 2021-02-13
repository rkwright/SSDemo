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
        
        ShapeUtil.drawAxes(scene: scnScene, height: 50, radius: 0.2)
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
                                                    //  10e6 km          km                  days                 hours 
        planets.append( PlanetParm(name: "sun",     orbitRadius: 0.01,   diameter: 1.3927e6, yearLength: 1.0,     dayLength: 0 ))
        planets.append( PlanetParm(name: "mercury", orbitRadius: 57.9,   diameter: 4879,     yearLength: 88.0,    dayLength: 4222.6 ))
        planets.append( PlanetParm(name: "venus",   orbitRadius: 108.2,  diameter: 12104,    yearLength: 224.7,   dayLength: 2802.0  ))
        planets.append( PlanetParm(name: "earth",   orbitRadius: 149.6,  diameter: 12756,    yearLength: 365.25,  dayLength: 24 ))
        planets.append( PlanetParm(name: "mars",    orbitRadius: 227.9,  diameter: 6792,     yearLength: 687.0,   dayLength: 24.7 ))
        planets.append( PlanetParm(name: "jupiter", orbitRadius: 778.6,  diameter: 142984,   yearLength: 4331.0,  dayLength: 9.9 ))
        planets.append( PlanetParm(name: "saturn",  orbitRadius: 1433.5, diameter: 120536,   yearLength: 10747.0, dayLength: 10.7 ))
        planets.append( PlanetParm(name: "uranus",  orbitRadius: 2872.5, diameter: 51118,    yearLength: 30589,   dayLength: 17.2 ))
        planets.append( PlanetParm(name: "neptune", orbitRadius: 4495.1, diameter: 49528,    yearLength: 59800,   dayLength: 16.1 ))
        planets.append( PlanetParm(name: "pluto",   orbitRadius: 5906.4, diameter: 2370,     yearLength: 90560,   dayLength: 153.3 ))

    }
    
    //
    // Walk through the table (TODO) and instantiate the celestial objects
    //
    func createSolarSystem () {
        
        // add in the Sun, then the rest of the planets
        
        for i in 0...planets.count-1 {
            createPlanet(parms: planets[i])
        }
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
