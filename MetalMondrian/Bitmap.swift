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
}

extension RGBAPixel : Pixel {
  public static var empty : RGBAPixel {
    get {
      return RGBAPixel(r: 0, g: 0, b: 0, a: 255)
    }
  }
  
  public static var bytes : Int {
    get {
      return 4
    }
  }
}

public protocol Pixel {
  static var bytes : Int { get }
  static var empty : Self { get }
}

public class Bitmap<T> where T : Pixel {
  let width:Int
  let height:Int
  
  var storage: [T]
  
  let storageLength : Int
  
  public var pixels : Int {
    get {
      return width * height
    }
  }
  
  func location(x:Int, y:Int) -> Int {
    return width * y + x
  }
  
  public func set(x:Int, y:Int, pixel: T) {
    storage[location(x: x, y: y)] = pixel
  }
  
  public init(width:Int, height:Int)  {
    self.width = width
    self.height = height

    let sl = width * height * T.bytes
    self.storageLength = sl
   
    self.storage = Array(repeating: T.empty, count: sl)
  }
}
