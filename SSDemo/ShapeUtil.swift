//
//  LineNode.swift
//  SSDemo
//
//  Created by rkwright on 2/7/21.
//

import UIKit
import SceneKit

class ShapeUtil
{
    static func makeCylinder( v1:              SCNVector3,      // where line starts
                              v2:              SCNVector3,      // where line ends
                              radius:          CGFloat,         // line thicknes
                              radSegmentCount: Int,             // number of sides of the line
                              material:        [SCNMaterial] )  // any material.
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
    //
    //
    static func makeSphere( pos: SCNVector3, radius: Double, color: UIColor ) ->SCNNode {
        
        var shapeNode : SCNNode
        var geomNode  : SCNGeometry
        
        geomNode = SCNSphere(radius: 1.0)
        
        shapeNode = SCNNode(geometry: geomNode)
        geomNode.materials.first?.diffuse.contents = color
        
        shapeNode.position = pos
        
        return shapeNode
    }
    

}
