//
//  RenderState.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 13/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//


import UIKit

public enum StyleModel : String {
  case candy
  case feathers
  case laMuse
  case mosaic
  case theScream
  case udnie
}

public enum StyleStatus {
  case running
  case idle
}

public class RenderState {
  var drawing: Bitmap<RGBAPixel>
  var drawingVersion : Int = 0
  var model : StyleModel = .mosaic
  var color : RGBAPixel = RGBAPixel.opaqueBlack
  
  public init(drawing: Bitmap<RGBAPixel>) {
    self.drawing = drawing
  }
  
  public func stylizeVersion() -> StylizeVersion {
    return StylizeVersion(drawingVersion: drawingVersion, style: model)
  }
  
  public func drawAt(point:CGPoint) {
    let point = Point(x: Int(point.x), y: Int(point.y))
    let brush = Rect.around(p: point, halfWidth: 3, halfHeight: 3)
    if let intersection = drawing.rect.intersect(other: brush) {
      for x in intersection.mn.x..<intersection.mx.x {
        for y in intersection.mn.y..<intersection.mx.y {
          drawing.set(x: x, y: y, pixel: color)
        }
      }
    } else {
      print("no intersection")
    }
    
    self.drawingVersion += 1
  }
}


