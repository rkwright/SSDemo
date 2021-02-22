//
//  SSViewController.swift
//  SSDemo
//
//  Created by rkwright on 2/4/21.
//

import UIKit
import SceneKit

struct PlanetParm {
    let name        : String    // name of celestial body as well as the root of the image name
    let orbitRadius : Float     // radius of the orbit (millions of km)
    let diameter    : Float     // diameter of the celestial body (km)
    let yearLength  : Float     // planet's rotational period, in days
    let dayLength   : Float     // planet's own rotational period, i.e. daylength, in hours

    let yearScale   : Float = 8 / 365  // from orbital period in days to seconds on screen
    let dayScale    : Float = 1 / 24   // from day rotation period in hours to seconds on screen
    let orbitScale  : Float       // from millions of km to absolute units on screen
    let diamScale   : Float       // from km to absolute units on screen
 
    // define the conversions needed
    let maxNodeDiam  : Float = 1.0
    let minNodeDiam  : Float = 0.2
    let maxDiam      : Float = 142984   // jupiter
    let minDiam      : Float = 4879     // mercury
    
    let maxNodeOrbit : Float = 40.0
    let minNodeOrbit : Float = 1.5
    let maxOrbit     : Float = 90560.0  // pluto
    let minOrbit     : Float = 57.9     // mercury

    init( name: String, orbitRadius: Double, diameter: Double, yearLength: Double, dayLength: Double) {
        self.name = name
        self.orbitRadius = Float(orbitRadius)
        self.diameter = Float(diameter)
        self.yearLength = Float(yearLength)
        self.dayLength = Float(dayLength)
        
        diamScale = (maxNodeDiam - minNodeDiam) / (log(maxDiam) - log(minDiam))
        orbitScale = (maxNodeOrbit - minNodeOrbit) / (log(maxOrbit) - log(minOrbit))
        
        print("orbitScale: ", orbitScale)
    }
    
    func getScaledOrbit() -> Float {
        return minNodeOrbit + (log(self.orbitRadius) - log(minOrbit)) * orbitScale
    }
    
    func getScaledDiam() -> Float {
        return minNodeDiam + (log(self.diameter) - log(minDiam)) * diamScale
    }
    
    //
    // Get the length of a single day, converted to seconds, based on Earth day of 1 second
    //
    func getDayLenSec () -> Float {
        return self.dayLength * dayScale
    }
    
    //
    // Get the length of a single year, converted to seconds, based on Earth year of 8 seconds
    //
    func getYearLenSec () -> Float {
        return self.yearLength * yearScale
    }
}

//-------------------------------------------------------
struct SemiLogFit {
    let d0,d1,s0,s1 : Double
    let slope       : Double
    
    init( d0: Double, d1: Double, s0: Double, s1: Double ) {
        self.d0 = d0
        self.d1 = d1
        self.s0 = s0
        self.s1 = s1
        
        slope = (s1 - s0) / (log(d1) - log(d0))
    }
    
    //
    // Use the semilog equation to predict new value
    //
    func calc ( x: Double) -> Double {
        return pow((log(x) - log(d0) * slope),10) + s0
    }
}

//----------------------------------------------------------

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
        
        ShapeUtil.drawAxes(scene: scnScene, height: 50, radius: 0.4)
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
        
        print("Name: ", parms.name," scaledDiam: ", parms.getScaledDiam())
        
        let planetGeom = SCNSphere(radius: CGFloat(parms.getScaledDiam())/1.0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "\(parms.name).jpg")
        planetGeom.materials = [material]

        let planet = SCNNode(geometry: planetGeom)
        
        var scaledOrbit = parms.getScaledOrbit();
        
        if parms.name.caseInsensitiveCompare("sun") == ComparisonResult.orderedSame {
            print("Sun!!")
            scaledOrbit = 0.1
            planetGeom.radius = 1.0
        }
        
        // Use the image name as a label - fragile!
        planet.name = parms.name
        planet.position = SCNVector3(x: scaledOrbit, y: 0, z: 0)

        print("scaledOrbit: ", scaledOrbit)

        ShapeUtil.rotateObject(obj: planet, rotation: Float.pi*2, duration: parms.getDayLenSec())

        print("dayLenSec: ", parms.getDayLenSec())

        let orbit = createOrbit(orbitRadius: scaledOrbit)
        orbit.addChildNode(planet)
        ShapeUtil.rotateObject(obj: orbit, rotation: Float.pi*2, duration: parms.getYearLenSec())
        
        print("yearLenSec: ", parms.getYearLenSec())

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

        return orbitNode
    }

    //
    // Set up the "database" of planets
    //
    func setupPlanets () {
                                                    //  10e6 km          km                  days                 hours
        planets.append( PlanetParm(name: "sun",     orbitRadius: 0.025,   diameter: 1.3927e6, yearLength: 3650.0,     dayLength: 27 ))
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
