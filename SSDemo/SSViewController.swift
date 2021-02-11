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
        
        //drawAxes(height: 10)
        linesTest(scene: scnScene)
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
    // Set up an Action for the supplied object
    //
    func rotateObject ( obj: SCNNode, rotation: Float, duration: Float ) {
        
        let rotation = SCNAction.rotateBy(x:0,y:CGFloat(rotation),z:0, duration: TimeInterval(duration))
        obj.runAction(SCNAction.repeatForever(rotation))
    }
  
    enum AXES : Int {
        case X_AXIS
        case Y_AXIS
        case Z_AXIS
    }
    
    //
    //
    //
    func drawAxis ( axis: AXES, axisColor: Int, axisHeight: Double ) {
        let        AXIS_RADIUS   =    axisHeight/20.0
        let        AXIS_HEIGHT   =    axisHeight
        let        AXIS_STEP     =    axisHeight/2.0
        let        AXIS_SEGMENTS = 32
        let        AXIS_GRAY     = 0x777777
        let        AXIS_WHITE    = 0xEEEEEE
        
        var     curColor:Int = AXIS_WHITE
        var cylNode : SCNNode
        var geomNode  : SCNGeometry

        
        
            //console.log("drawAxis " + axis + " ht: " +  AXIS_HEIGHT + ", " + AXIS_STEP + " color: " + axisColor);
        
        let numSteps = round(AXIS_HEIGHT/AXIS_STEP)
        for i in 0...20 {
            
            //console.log("loop " +  i);
                
            var pos = -AXIS_HEIGHT / 2 + Double(i) * AXIS_STEP;
        
            if (i & 1) == 0 {
                curColor = axisColor;
            } else if (pos < 0) {
                curColor = AXIS_GRAY;
            } else {
                curColor = AXIS_WHITE;
            }
                //console.log(i + " pos: " + pos + " color: " + curColor);
                
            // var geometry = new THREE.CylinderGeometry( AXIS_RADIUS, AXIS_RADIUS, AXIS_STEP, AXIS_SEGMENTS );
            geomNode = SCNCylinder(radius: CGFloat(AXIS_RADIUS), height: CGFloat(AXIS_STEP))
            geomNode.materials.first?.diffuse.contents = curColor
     
            cylNode = SCNNode(geometry: geomNode)
      
            pos += AXIS_STEP/2.0;
            if axis == AXES.X_AXIS {
                cylNode.position.x = Float(pos);
                cylNode.rotation.z = Float.pi
            }
            else if axis == AXES.Y_AXIS {
                cylNode.rotation.y = Float.pi / 2.0
                cylNode.position.y = Float(pos);
            }
            else {
                cylNode.position.z = Float(pos);
                cylNode.rotation.x = Float.pi / 2.0
            }
                
                //this.scene.add( cylinder );
            scnScene.rootNode.addChildNode(cylNode)

        }
    }

    func drawAxes ( height: Double ) {
        
        drawAxis(axis: AXES.X_AXIS, axisColor: 0xff0000, axisHeight: height);
        drawAxis(axis: AXES.Y_AXIS, axisColor: 0x00ff00, axisHeight: height);
        drawAxis(axis: AXES.Z_AXIS, axisColor: 0x0000ff, axisHeight: height);
    }
    
    //------------------------- App-specific ---------------------

    //
    // Just a near-trivial test of the ckinder/line generating code
    //
    func linesTest( scene: SCNScene ) {
        let mat = SCNMaterial()
        mat.diffuse.contents  = UIColor.white
        mat.specular.contents = UIColor.white
        
        // draw 100 lines (as cylinders) between random points.
        for _ in 1...100 {
            let v1 =  SCNVector3( x: Float.random(in: -50...50),
                                  y: Float.random(in: -50...50),
                                  z: Float.random(in: -50...50) )
            
            let v2 =  SCNVector3( x: Float.random(in: -50...50),
                                  y: Float.random(in: -50...50),
                                  z: Float.random(in: -50...50) )
            
            // Just for testing, add two little spheres to check if lines are drawn correctly:
            // each line should run exactly from a green sphere to a red one
            scene.rootNode.addChildNode( ShapeUtil.makeSphere( scene: scene, pos:v1, radius: 0.5, color: UIColor.green))
            scene.rootNode.addChildNode( ShapeUtil.makeSphere( scene:scene, pos:v2, radius: 0.5, color: UIColor.red))
            
            // Have to pass the parentnode because
            // it is not known during class instantiation of LineNode.
            
            let ndLine = ShapeUtil.makeCylinder( parent: scene.rootNode,  //  needed
                                       v1: v1,                // line (cylinder) starts here
                                       v2: v2,                // line ends here
                                       radius: 0.2,           // line thickness
                                       radSegmentCount: 6,    // hexagon tube
                                       material: [mat] )      // any material
            
            scene.rootNode.addChildNode(ndLine)
        }
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
        rotateObject(obj: sun, rotation: -0.3, duration: 1)
        scnScene.rootNode.addChildNode(sun)

        // then Mercury
        let mercuryOrbit = createOrbit(orbitRadius: 1.9)
        let mercury = createPlanet(parms: planets[1])
        rotateObject(obj: mercury, rotation: 0.6, duration: 0.4)
        rotateObject(obj: mercuryOrbit, rotation: 0.6,  duration: 1)
        mercuryOrbit.addChildNode(mercury)
        scnScene.rootNode.addChildNode(mercuryOrbit)
        
        // then Venus
        let venusOrbit = createOrbit(orbitRadius: 3.5)
        let venus = createPlanet(parms: planets[2])
        rotateObject(obj: venus, rotation: 0.6, duration: 0.4)
        rotateObject(obj: venusOrbit, rotation: 0.6,  duration: 1)
        venusOrbit.addChildNode(venus)
        scnScene.rootNode.addChildNode(venusOrbit)
        
        // then Mars
        let marsOrbit = createOrbit(orbitRadius: 4.0)
        let mars = createPlanet(parms: planets[3])
        rotateObject(obj: mars, rotation: 0.6, duration: 0.4)
        rotateObject(obj: marsOrbit, rotation: 0.6,  duration: 1)
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

