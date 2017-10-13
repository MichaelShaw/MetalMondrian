//
//  RenderState.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 13/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import Foundation


public class RenderState {
  let drawing: Bitmap<RGBAPixel>
  var drawingDirty : Bool = true
  // primary buffer
  // last mondrian
  // background req
  // model type selected
  
  public init(drawing: Bitmap<RGBAPixel>) {
    self.drawing = drawing
    self.drawingDirty = true
  }
}


