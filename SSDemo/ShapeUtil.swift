//
//  ShapeUtil.swift
//  First used in SSDemo
//
//  Created by rkwright on 2/7/21.
//

import UIKit
import SceneKit

class ShapeUtil
{
    static func makeCylinder( v1:              SCNVector3,      // where cylinder starts
                              v2:              SCNVector3,      // where cylinder ends
                              radius:          CGFloat,         // cylinder thicknes
                              radSegmentCount: Int,             // number of sides of the cylinder
                              material:        [SCNMaterial] )  // some material.
                         -> SCNNode {
        let node = SCNNode()
        
        let height = sqrt( pow(v1.x-v2.x,2) + pow(v1.y-v2.y,2) + pow(v1.z-v2.z,2))
        
        node.position = v1
        
        let ndV2 = SCNNode()
        
        ndV2.position = v2
        let ndZAlign = SCNNode()
        ndZAlign.eulerAngles.x = Float.pi/2
        
        let cylGeom = SCNCylinder(radius: radius, height: CGFloat(height))
        cylGeom.radialSegmentCount = radSegmentCount
        cylGeom.materials = material
        
        let ndCylinder = SCNNode(geometry: cylGeom )
        ndCylinder.position.y = -height/2
        ndZAlign.addChildNode(ndCylinder)
        
        node.addChildNode(ndZAlign)
        
        node.constraints = [SCNLookAtConstraint(target: ndV2)]
        
        return node
    }
    
    //
    // Simply create and return a sphere.
    //
    static func makeSphere( pos: SCNVector3, radius: Double, color: UIColor ) ->SCNNode {
        
        var shapeNode : SCNNode
        var geomNode  : SCNGeometry
        
        geomNode = SCNSphere(radius: CGFloat(radius))
        
        shapeNode = SCNNode(geometry: geomNode)
        geomNode.materials.first?.diffuse.contents = color
        
        shapeNode.position = pos
        
        return shapeNode
    }
    
    //
    // Simple util - why doesn't Swift have this?
    //
    static func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //
    // Set up an Action for the supplied object
    //
    static func rotateObject ( obj: SCNNode, rotation: Float, duration: Float ) {
        
        let rotation = SCNAction.rotateBy(x:0,y:CGFloat(rotation),z:0, duration: TimeInterval(duration))
        obj.runAction(SCNAction.repeatForever(rotation))
    }
  
    //--------------------- AXES subsection ---------------------------
    
    enum AXES : Int {
        case X_AXIS
        case Y_AXIS
        case Z_AXIS
    }
    
    //
    // Draw single XYZ axis
    //
    static func drawAxis ( scene: SCNScene, axis: AXES, axisColor: UIColor, axisHeight: Double, radius: Double ) {
        let        axisStep  : Float   = Float(axisHeight)/20.0
        let        axisGray  : UIColor = UIColor.lightGray
        let        axisWhite : UIColor = UIColor.white
        
        var        curColor  : UIColor
        var        v1        : SCNVector3
        var        v2        : SCNVector3

       // let numSteps = round(AXIS_HEIGHT/AXIS_STEP)
        for i in 0...20 {
                
            let pos = -axisHeight / 2 + Double(i) * Double(axisStep)
        
            curColor = (i & 1) != 0 ? axisColor : (pos < 0) ? axisGray : axisWhite

            let mat = SCNMaterial()
            mat.diffuse.contents = curColor

            v1 = SCNVector3(0,0,0)
            v2 = SCNVector3(0,0,0)
            
            if axis == AXES.X_AXIS {
                v1.x = Float(pos);
                v2.x = Float(pos) + axisStep
            }
            else if axis == AXES.Y_AXIS {
                v1.y = Float(pos);
                v2.y = Float(pos) + axisStep
            }
            else {
                v1.z = Float(pos);
                v2.z = Float(pos) + axisStep
            }
  
            let cylNode = ShapeUtil.makeCylinder( v1: v1,                // line (cylinder) starts here
                                                  v2: v2,                // line ends here
                                                  radius: 0.1,           // line thickness
                                                  radSegmentCount: 6,    // hexagon tube
                                                  material: [mat] )      // any material
              
            scene.rootNode.addChildNode(cylNode)
        }
    }

    //
    // Draw the three axes...
    //
    static func drawAxes ( scene: SCNScene, height: Double, radius: Double ) {
        
        drawAxis(scene: scene, axis: AXES.X_AXIS, axisColor: UIColor.red, axisHeight: height, radius: radius);
        drawAxis(scene: scene, axis: AXES.Y_AXIS, axisColor: UIColor.green, axisHeight: height, radius: radius);
        drawAxis(scene: scene, axis: AXES.Z_AXIS, axisColor: UIColor.blue, axisHeight: height, radius: radius);
    }
    
    //------------------------- Testing ---------------------

    //
    // Just a near-trivial test of the ckinder/line generating code
    //
    static func linesTest( scene: SCNScene ) {
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
            scene.rootNode.addChildNode( ShapeUtil.makeSphere( pos:v1, radius: 0.55, color: UIColor.green))
            scene.rootNode.addChildNode( ShapeUtil.makeSphere( pos:v2, radius: 0.5, color: UIColor.red))
            
            let cylinder = ShapeUtil.makeCylinder( v1: v1,                // line (cylinder) starts here
                                                   v2: v2,                // line ends here
                                                   radius: 0.2,           // line thickness
                                                   radSegmentCount: 6,    // hexagon tube
                                                   material: [mat] )      // any material
            
            scene.rootNode.addChildNode(cylinder)
        }
    }
}   // end of class
