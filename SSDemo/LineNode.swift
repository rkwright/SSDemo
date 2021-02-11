//
//  LineNode.swift
//  SSDemo
//
//  Created by rkwright on 2/7/21.
//

import UIKit
import SceneKit

class ShapeUtil: SCNNode
{
    init( parent:          SCNNode,         // because this node has not yet been assigned to a parent.
          v1:              SCNVector3,      // where line starts
          v2:              SCNVector3,      // where line ends
          radius:          CGFloat,         // line thicknes
          radSegmentCount: Int,             // number of sides of the line
          material:        [SCNMaterial] )  // any material.
    {
        super.init()
        
        let height = sqrt( pow(v1.x-v2.x,2) + pow(v1.y-v2.y,2) + pow(v1.z-v2.z,2))

        position = v1

        let ndV2 = SCNNode()

        ndV2.position = v2
        parent.addChildNode(ndV2)
        let ndZAlign = SCNNode()
        ndZAlign.eulerAngles.x = Float.pi/2

        let cylgeo = SCNCylinder(radius: radius, height: CGFloat(height))
        cylgeo.radialSegmentCount = radSegmentCount
        cylgeo.materials = material

        let ndCylinder = SCNNode(geometry: cylgeo )
        ndCylinder.position.y = -height/2
        ndZAlign.addChildNode(ndCylinder)

        addChildNode(ndZAlign)

        constraints = [SCNLookAtConstraint(target: ndV2)]
    }

    //
    // Compiler-required overrides
    //
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
 }

 //--------------------------------------

//
//
//
func makeSphere( scene: SCNScene, pos: SCNVector3, radius: Double, color: UIColor ) ->SCNNode {
    
    var shapeNode : SCNNode
    var geomNode  : SCNGeometry
        
    geomNode = SCNSphere(radius: 1.0)

    shapeNode = SCNNode(geometry: geomNode)
    geomNode.materials.first?.diffuse.contents = color

    shapeNode.position = pos
            
    //scene.rootNode.addChildNode(shapeNode)
    return shapeNode
}

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
        scene.rootNode.addChildNode( makeSphere( scene: scene, pos:v1, radius: 0.5, color: UIColor.green))
        scene.rootNode.addChildNode( makeSphere( scene:scene, pos:v2, radius: 0.5, color: UIColor.red))

        // Have to pass the parentnode because
        // it is not known during class instantiation of LineNode.

        let ndLine = ShapeUtil( parent: scene.rootNode,  //  needed
                               v1: v1,                // line (cylinder) starts here
                               v2: v2,                // line ends here
                               radius: 0.2,           // line thickness
                               radSegmentCount: 6,    // hexagon tube
                               material: [mat] )      // any material

        scene.rootNode.addChildNode(ndLine)
    }
}
