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
    print("state draw")
    
    let point = Point(x: Int(point.x), y: Int(point.y))
    
    drawing.set(p: point, pixel: RGBAPixel.opaqueBlack)
    
    
    self.drawingDirty = true
  }
}


