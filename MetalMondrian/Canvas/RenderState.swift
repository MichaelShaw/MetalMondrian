//
//  RenderState.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 13/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//


import UIKit

public enum StyleModel {
  case candy
  case feathers
  case laMuse
  case mosaic
  case theScream
  case udnie
}

public class RenderState {
  let drawing: Bitmap<RGBAPixel>
  var drawingDirty : Bool = true
  // last stylized version ... as a CVPixelBuffer? hrm
  
  // primary buffer
  // last mondrian
  // background req
  // model type selected
  
  public init(drawing: Bitmap<RGBAPixel>) {
    self.drawing = drawing
    self.drawingDirty = true
  }
  
  public func drawAt(point:CGPoint) {
    let point = Point(x: Int(point.x), y: Int(point.y))
    let brush = Rect.around(p: point, halfWidth: 5, halfHeight: 5)
    if let intersection = drawing.rect.intersect(other: brush) {
      let color = RGBAPixel.opaqueBlack
      for x in intersection.mn.x..<intersection.mx.x {
        for y in intersection.mn.y..<intersection.mx.y {
          drawing.set(x: x, y: y, pixel: color)
        }
      }
    } else {
      print("no intersection")
    }
    
    self.drawingDirty = true
  }
}


