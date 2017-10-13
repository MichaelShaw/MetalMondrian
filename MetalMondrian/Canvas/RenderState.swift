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
  
  public static var all : [StyleModel] = [.candy, .feathers, .laMuse, .mosaic, .theScream, .udnie]
  
  public var description: String {
    get {
      switch self {
      case .candy: return "Candy"
      case .feathers: return "Feathers"
      case .laMuse: return "La Muse"
      case .mosaic: return "Mosaic"
      case .theScream: return "The Scream"
      case .udnie: return "Udnie"
      }
    }
  }
}

public enum StyleStatus {
  case running
  case idle
}

public enum BlendMode : Int {
  case drawing
  case mix
  case style
  
  public var next : BlendMode {
    get {
      switch self {
      case .drawing: return .mix
      case .mix: return .style
      case .style: return .drawing
      }
    }
  }
  
  public var description: String {
    get {
      switch self {
      case .drawing: return "Drawing"
      case .mix: return "Mix"
      case .style: return "Stylized"
      }
    }
  }
}

public class RenderState {
  var drawing: Bitmap<RGBAPixel>
  var drawingVersion : Int = 0
  var model : StyleModel = .mosaic
  var color : RGBAPixel = RGBAPixel.opaqueBlack
  var blendMode : BlendMode = .mix
  
  public init(drawing: Bitmap<RGBAPixel>) {
    self.drawing = drawing
  }
  
  public func stylizeVersion() -> StylizeVersion {
    return StylizeVersion(drawingVersion: drawingVersion, style: model)
  }
  
  public func draw(from: Point?, to:Point) {
    let useFrom = from ?? to
    let distance = to.distanceTo(other: useFrom)
    let steps = Int(distance / 3.0) + 1
    
    for i in 0..<steps {
      let alpha : Double
      if steps == 1 {
        alpha = 1.0
      } else {
        alpha = Double(i) / Double(steps - 1)
      }
      
      let target = Point.lerp(a: useFrom, b: to, alpha: alpha)
      let brush = Rect.around(p: target, halfWidth: 3, halfHeight: 3)
      if let intersection = drawing.rect.intersect(other: brush) {
        for x in intersection.mn.x..<intersection.mx.x {
          for y in intersection.mn.y..<intersection.mx.y {
            drawing.set(x: x, y: y, pixel: color)
          }
        }
      } else {
        print("no intersection")
      }
    }
    

    

//
    self.drawingVersion += 1
  }
}


