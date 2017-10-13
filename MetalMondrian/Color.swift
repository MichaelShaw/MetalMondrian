//
//  Color.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 6/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import Foundation
import UIKit

public struct Math {}
public extension Math {
  public static func clamp<T: Comparable>(_ value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
  }
  
  public static func clamp(d: Double) -> Double {
    return min(max(d, 0.0), 1.0)
  }
}

public struct Color {
  public var r:UInt8
  public var g:UInt8
  public var b:UInt8
  public var a:UInt8
  
  public var opaque : Bool {
    get {
      return a == 255
    }
  }
  
  public func with(alpha:Double) -> Color {
    return with(alpha: UInt8(Math.clamp(Int(alpha * 255.0), lower: 0, upper: 255)))
  }
  
  public func with(alpha:UInt8) -> Color {
    return Color(r:r, g:g, b:b, a:alpha)
  }
  
  var uiColor: UIColor {
    get {
      return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }
  }
  
  var cgColor: CGColor {
    get {
      return self.uiColor.cgColor
    }
  }
  
  var toRgb: RGBAPixel {
    get {
      return RGBAPixel(r: r, g: g, b: b, a: a)
    }
  }
}

public extension Color {
  static let picoWhitish = Color.rgb(255, 241, 232)
  
  static let pico8 : [Color] = [
    Color.rgb(0, 0, 0),
    Color.rgb(29, 43, 83),
    Color.rgb(126, 32, 83),
    Color.rgb(0, 135, 81),
    Color.rgb(171, 82, 54),
    Color.rgb(95, 87, 79),
    Color.rgb(194, 195, 199),
    Color.rgb(255, 241, 232),
    Color.rgb(255, 0, 77),
    Color.rgb(255, 163, 0),
    Color.rgb(255, 236, 39),
    Color.rgb(0, 228, 54),
    Color.rgb(41, 173, 255),
    Color.rgb(131, 118, 156),
    Color.rgb(255, 119, 168),
    Color.rgb(255, 204, 170),
  ]
  
  static let clearWhite = Color.rgba(255, 255, 255, 0)
  static let clearBlack = Color.rgba(0, 0, 0, 0)
  static let white = Color.rgb(255, 255, 255)
  static let black = Color.rgb(0, 0, 0)
  static let pink = Color.rgb(255, 0, 255)
  static let red = Color.rgb(255, 0, 0)
  static let green = Color.rgb(0, 255, 0)
  static let blue = Color.rgb(0, 0, 255)
  static let placeholderText = white.with(alpha: 0.7)
  static let uiSwitchOnTint = Color.rgb(116, 201, 71)
  static let deleteActionBackground = Color.rgb(235, 54, 44)
  static let transluscentSelectedBackgroundColour = white.with(alpha: 0.3)
  
  static func blend(lhs:Color, _ rhs:Color, alpha:Double) -> Color {
    let r = Double(lhs.r) * (1-alpha) + Double(rhs.r) * alpha
    let g = Double(lhs.g) * (1-alpha) + Double(rhs.g) * alpha
    let b = Double(lhs.b) * (1-alpha) + Double(rhs.b) * alpha
    let a = Double(lhs.a) * (1-alpha) + Double(rhs.a) * alpha
    
    return Color.rgba(UInt8(r), UInt8(g), UInt8(b), UInt8(a))
  }
  
  static let grays = (0..<11).map { i -> Color in
    let v = UInt8(255 * i / 10)
    return Color.rgba(v,v,v, 255)
  }
  
  static let transWhites = (0..<11).map { i -> Color in
    return Color.rgba(255, 255, 255, UInt8(255 * i / 10))
  }
  
  static let transBlacks = (0..<11).map { i -> Color in
    return Color.rgba(0, 0, 0, UInt8(255 * i / 10))
  }
  
  static func rgb(_ r:UInt8, _ g:UInt8, _ b:UInt8) -> Color {
    return Color(r: r, g: g, b: b, a: 255)
  }
  
  static func rgba(_ r:UInt8, _ g:UInt8, _ b:UInt8, _ a:UInt8) -> Color {
    return Color(r: r, g: g, b: b, a: a)
  }
}
