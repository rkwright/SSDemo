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
    static func makeCylinder( parent:          SCNNode,         // because this node has not yet been assigned to a parent.
                       v1:              SCNVector3,      // where line starts
                       v2:              SCNVector3,      // where line ends
                       radius:          CGFloat,         // line thicknes
                       radSegmentCount: Int,             // number of sides of the line
                       material:        [SCNMaterial] ) ->SCNNode // any material.
    {
        let node = SCNNode()
        
        let height = sqrt( pow(v1.x-v2.x,2) + pow(v1.y-v2.y,2) + pow(v1.z-v2.z,2))
        
        node.position = v1
        
        let ndV2 = SCNNode()
        
        ndV2.position = v2
        parent.addChildNode(ndV2)
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
    // Compiler-required overrides
    //
    /*
     override init() {
     super.init()
     }
     required init?(coder aDecoder: NSCoder) {
     super.init(coder: aDecoder)
     }
     */
    
    
    //--------------------------------------
    
    //
    //
    //
    static func makeSphere( scene: SCNScene, pos: SCNVector3, radius: Double, color: UIColor ) ->SCNNode {
        
        var shapeNode : SCNNode
        var geomNode  : SCNGeometry
        
        geomNode = SCNSphere(radius: 1.0)
        
        shapeNode = SCNNode(geometry: geomNode)
        geomNode.materials.first?.diffuse.contents = color
        
        shapeNode.position = pos
        
        //scene.rootNode.addChildNode(shapeNode)
        return shapeNode
    }
    

}
