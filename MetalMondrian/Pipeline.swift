//
//  Pipeline.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 6/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import Metal
import UIKit


let coloredTrianglePositions : [ColoredVertex] = [
    ColoredVertex(x: 0.0, y: 1.0, z: 0.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0),
    ColoredVertex(x: -1.0, y: -1.0, z: 0.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0),
    ColoredVertex(x: 1.0, y: -1.0, z: 0.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)
]

let fatTriangle : [FatVertex] = [
    FatVertex(x: 0.0, y: 1.0, z: 0.0, u: 0.0, v: 1.0,r: 1.0,  g: 0.0, b: 0.0, a: 1.0),
    FatVertex(x: -1.0, y: -1.0, z: 0.0, u: 1.0, v: 0.0, r: 0.0,  g: 1.0, b: 0.0, a: 1.0),
    FatVertex(x: 1.0, y: -1.0, z: 0.0, u:1.0, v: 1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)
]


func fatSquare() -> [FatVertex] {
  let tl = FatVertex(x: -1.0, y: 1.0, z: 0.0, u: 0.0, v: 0.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0)
  let tr = FatVertex(x: 1.0,  y: 1.0, z: 0.0, u: 1.0, v: 0.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0)

  let bl = FatVertex(x: -1.0, y: -1.0, z: 0.0, u: 0.0, v: 1.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0)
  let br = FatVertex(x: 1.0,  y: -1.0, z: 0.0, u: 1.0, v: 1.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0)

  return [tl, bl, tr, tr, bl, br]
}


struct ColoredVertex {
    var x,y,z: Float     // position data
    var r,g,b,a: Float   // color data
}

struct FatVertex {
    var x,y,z: Float     // position data
    var u,v: Float
    var r,g,b,a: Float   // color data
}

class Tesselator<T> {
    var verticies: [T]
    
    public init() {
        self.verticies = []
    }
    
    public func push(_ ele:T) {
        self.verticies.append( ele )
    }
    
    public func clear() {
        self.verticies.removeAll(keepingCapacity: true)
    }
    
    public func createGeometry(device:MTLDevice) -> GeometryData<T>? {
        let dataSize = verticies.count * MemoryLayout.size(ofValue: verticies[0])
        if let buffer = device.makeBuffer(bytes: self.verticies, length: dataSize, options: []) {
            return GeometryData(vertexBuffer: buffer, vertexCount: verticies.count)
        } else {
            return nil
        }
    }
}

class GeometryData<T> {
    let vertexBuffer : MTLBuffer
    let vertexCount : Int
    
    public init(vertexBuffer:MTLBuffer, vertexCount:Int) {
        self.vertexBuffer = vertexBuffer
        self.vertexCount = vertexCount
    }
}



func createPipeline(device:MTLDevice) -> MTLRenderPipelineState {
    let lib = device.makeDefaultLibrary()!
    
    let pipelineDescription = MTLRenderPipelineDescriptor()
    pipelineDescription.vertexFunction = lib.makeFunction(name: "basic_vertex")
    pipelineDescription.fragmentFunction = lib.makeFunction(name: "basic_fragment")
    pipelineDescription.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    return try! device.makeRenderPipelineState(descriptor: pipelineDescription)
}
