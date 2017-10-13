//
//  Bitmap.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 13/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import Foundation

public struct RGBAPixel {
  public var r: UInt8
  public var g: UInt8
  public var b: UInt8
  public var a: UInt8
  
  public var toBGRA : BGRAPixel {
    get {
      return BGRAPixel(b: b, g: g, r: r, a: a)
    }
  }
}

extension RGBAPixel : Equatable {
  
}

public func ==(lhs:RGBAPixel, rhs:RGBAPixel) -> Bool {
  return lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b && lhs.a == rhs.a
}

public struct BGRAPixel {
  public var b: UInt8
  public var g: UInt8
  public var r: UInt8
  public var a: UInt8
  
  public var toRGBA : RGBAPixel {
    get {
      return RGBAPixel(r: r, g: g, b: b, a: a)
    }
  }
}

extension BGRAPixel : Pixel {
  public static var bytes : Int {
    get {
      return 4
    }
  }
  
  public static let opaqueBlack : BGRAPixel = BGRAPixel(b: 0, g: 0, r: 0, a: 255)
}


extension RGBAPixel : Pixel {
  public static let opaqueBlack : RGBAPixel = RGBAPixel(r: 0, g: 0, b: 0, a: 255)
  public static let opaqueWhite : RGBAPixel =  RGBAPixel(r: 255, g: 255, b: 255, a: 255)
  
  public static var bytes : Int {
    get {
      return 4
    }
  }
}

public protocol Pixel {
  static var bytes : Int { get }
}

public struct Point {
  public var x : Int
  public var y : Int
  
  public func distanceTo(other:Point) -> Double {
    let deltaX = abs(self.x - other.x)
    let deltaY = abs(self.y - other.y)
    
    return sqrt(Double(deltaX * deltaX + deltaY * deltaY))
  }
  
  public static func lerp(a: Point, b:Point, alpha: Double) -> Point {
    let nAlpha = 1.0 - alpha
    let x = Double(a.x) * nAlpha + Double(b.x) * alpha
    let y = Double(a.y) * nAlpha + Double(b.y) * alpha
    return Point(x: Int(x), y: Int(y))
  }
}

public struct Rect {
  public var mn: Point
  public var mx: Point
  
  public var defunct : Bool {
    get {
      return self.mx.x < self.mn.x || self.mx.y < self.mn.y
    }
  }
  
  public static func around(p:Point, halfWidth:Int, halfHeight:Int) -> Rect {
    return Rect(mn: Point(x: p.x - halfWidth, y: p.y - halfHeight),
                mx: Point(x: p.x + halfWidth, y: p.y + halfHeight))
  }
  
  public func intersect(other:Rect) -> Rect? {
    let rect = Rect(mn: Point(x: max(self.mn.x, other.mn.x), y: max(self.mn.y, other.mn.y)),
                    mx: Point(x: min(self.mx.x, other.mx.x), y: min(self.mx.y, other.mx.y)))
    if rect.defunct {
      return nil
    } else {
      return rect
    }
  }
}


public struct Bitmap<T> where T : Pixel {
  let width:Int
  let height:Int
  
  var storage: [T]
  
  let storageLength : Int
  
  public var rect : Rect {
    get {
      return Rect(mn: Point(x: 0, y: 0), mx: Point(x: width, y: height))
    }
  }
  
  public var pixels : Int {
    get {
      return width * height
    }
  }
  
  func location(x:Int, y:Int) -> Int {
    return width * y + x
  }
  
  public mutating func set(x:Int, y:Int, pixel: T) {
    storage[location(x: x, y: y)] = pixel
  }
  
  public mutating func set(p:Point, pixel: T) {
    storage[location(x: p.x, y: p.y)] = pixel
  }
}

func map<A, B>(bmp:Bitmap<A>, f: (A) -> B) -> Bitmap<B> where B: Pixel {
  let newStorage : [B] = bmp.storage.map(f)
  let sl = bmp.width * bmp.height * B.bytes
  return Bitmap.init(width: bmp.width, height: bmp.height, storage: newStorage, storageLength: sl)
}

func bitmapWithDefault<T>(width:Int, height:Int, defaultPixel: T) -> Bitmap<T> where T : Pixel {
  let sl = width * height * T.bytes
  let storage = Array(repeating: defaultPixel, count: sl)
  return Bitmap(width: width, height: height, storage: storage, storageLength: sl)
}
