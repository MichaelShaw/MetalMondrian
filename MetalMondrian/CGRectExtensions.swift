//
//  CGRectExtensions.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 13/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import Foundation
import UIKit


public struct CGExtensions {
  public static func verticallyCenter(height:CGFloat, container:CGFloat) -> (top:CGFloat, bottom: CGFloat) {
    let padding = (container - height) / 2.0
    return (padding, height + padding)
  }
}

public extension CGRect {
  static var epsilon : CGFloat = 0.0001
  
  static func from(left: CGFloat, right:CGFloat, top:CGFloat, bottom:CGFloat) -> CGRect {
    return CGRect(x: left, y: top, width: right - left, height: bottom - top)
  }
  
  static func from(centre: CGPoint, size:CGSize) -> CGRect {
    let halfSize = size * 0.5
    return CGRect(origin: centre - halfSize, size: size)
  }
  
  var defunct : Bool {
    get {
      return self.width < CGRect.epsilon || self.height < CGRect.epsilon
    }
  }
  
  var left : CGFloat {
    get { return origin.x }
  }
  
  var right : CGFloat {
    get { return origin.x + width }
  }
  
  var top : CGFloat {
    get { return origin.y }
  }
  
  var bottom : CGFloat {
    get { return origin.y + height }
  }
  
  var midTop: CGPoint {
    get {
      return CGPoint(x: self.origin.x + self.width / 2.0, y: top)
    }
  }
  
  var midBottom: CGPoint {
    get {
      return CGPoint(x: self.origin.x + self.width / 2.0, y: bottom)
    }
  }
  
  var midLeft: CGPoint {
    get {
      return CGPoint(x: left, y: self.origin.y + self.height / 2.0)
    }
  }
  
  var midRight: CGPoint {
    get {
      return CGPoint(x: right, y: self.origin.y + self.height / 2.0)
    }
  }
  
  var centre: CGPoint {
    get {
      return CGPoint(x: self.origin.x + self.width / 2.0, y: self.origin.y + self.height / 2.0)
    }
  }
  
  var topLeft : CGPoint {
    get {
      return self.origin
    }
  }
  
  var topRight : CGPoint {
    get {
      return CGPoint(x: right, y: top)
    }
  }
  
  var bottomRight : CGPoint {
    get {
      return CGPoint(x: right, y: bottom)
    }
  }
  
  var bottomLeft : CGPoint {
    get {
      return CGPoint(x: left, y: bottom)
    }
  }
  
  func padded(by:CGFloat) -> CGRect {
    return self.insetBy(dx: by, dy: by)
  }
  
  func leftBy(_ d:CGFloat) -> CGRect {
    return CGRect(origin: self.origin.leftBy(d), size: self.size)
  }
  
  func rightBy(_ d:CGFloat) -> CGRect {
    return CGRect(origin: self.origin.rightBy(d), size: self.size)
  }
  
  func upBy(_ d:CGFloat) -> CGRect {
    return CGRect(origin: self.origin.upBy(d), size: self.size)
  }
  
  func downBy(_ d:CGFloat) -> CGRect {
    return CGRect(origin: self.origin.downBy(d), size: self.size)
  }
  
  func quartered() -> (topLeft:CGRect, topRight:CGRect, bottomLeft:CGRect, bottomRight:CGRect) {
    let (top, bottom) = self.splitTopBottom()
    let (tl, tr) = top.splitLeftRight()
    let (bl, br) = bottom.splitLeftRight()
    return (tl, tr, bl, br)
  }
  
  func splitTop(_ d:CGFloat) -> (top:CGRect, bottom:CGRect) {
    let top = CGRect(origin: self.origin, size: CGSize(width: size.width, height: CGFloat(d)))
    let bottom = CGRect(origin: self.origin.downBy(d), size:CGSize(width: size.width, height: size.height - CGFloat(d)))
    return (top, bottom)
  }
  
  func split(top:CGFloat, middle:CGFloat) -> (top:CGRect, middle:CGRect, bottom:CGRect) {
    let (top, rest) = splitTop(top)
    let (middle, bottom) = rest.splitTop(middle)
    return (top, middle, bottom)
  }
  
  func split(middle:CGFloat, bottom:CGFloat) -> (top:CGRect, middle:CGRect, bottom:CGRect) {
    let (rest, bottom) = split(bottom: bottom)
    let (top, middle) = rest.split(bottom: middle)
    return (top, middle, bottom)
  }
  
  func split(padding:CGFloat, top:CGFloat, middle:CGFloat) -> (top:CGRect, middle:CGRect, bottom:CGRect) {
    let (t, rest) = self.splitTop(top)
    let rRest = rest.withoutTop(padding)
    
    let (m, _, b) = rRest.split(top: middle, middle: padding)
    
    return (t, m, b)
  }
  
  func split(padding:CGFloat, middle:CGFloat, bottom:CGFloat) -> (top:CGRect, middle:CGRect, bottom:CGRect) {
    let (rest, b) = self.split(bottom: bottom)
    
    let rRest = rest.withoutBottom(padding)
    
    let (t, _, m) = rRest.split(middle: padding, bottom: middle)
    
    return (t, m, b)
  }
  
  func splitQuad(padding:CGFloat) -> (tl:CGRect, tr:CGRect, bl:CGRect, br:CGRect) {
    let (l, r) = self.horizontalSplitWith(dividingMargin: padding)
    let (tl, bl) = l.verticallySplitWith(dividingMargin: padding)
    let (tr, br) = r.verticallySplitWith(dividingMargin: padding)
    return (tl, tr, bl, br)
  }
  
  func split(left leftWidth:CGFloat, middle middleWidth:CGFloat) -> (left:CGRect, middle:CGRect, right:CGRect) {
    let (left, rest) = split(left:leftWidth)
    let (middle, right) = rest.split(left:middleWidth)
    return (left, middle, right)
  }
  
  func horizontalSplitWith(dividingMargin:CGFloat) -> (left:CGRect, right:CGRect) {
    let widthPerSegment = (self.width - dividingMargin) / 2.0
    let (l, _, r) = split(left: widthPerSegment, middle: dividingMargin)
    return (l, r)
  }
  
  func horizontalSplitWith(padding:CGFloat, count:Int) -> [CGRect] {
    assert(count >= 0, "horizontalSplitWith(padding,count) needs a count of > 0")
    if count == 0 {
      return []
    } else {
      let paddingCost = padding * CGFloat(count - 1)
      let perContentWidth = (self.width - paddingCost) / CGFloat(count)
      
      let contentSize = CGSize(width: perContentWidth, height: self.height)
      
      var rects : [CGRect] = []
      for i in 0..<count {
        let startX = CGFloat(i) * (padding + perContentWidth)
        rects.append(CGRect(origin: CGPoint(x:origin.x + startX, y:origin.y), size: contentSize))
      }
      return rects
    }
  }
  
  func verticallySplitWith(dividingMargin:CGFloat) -> (left:CGRect, right:CGRect) {
    let heightPerSegment = (self.height - dividingMargin) / 2.0
    let (t, _, b) = split(top: heightPerSegment, middle: dividingMargin)
    return (t, b)
  }
  
  func split(bottom:CGFloat) -> (top:CGRect, bottom:CGRect) {
    return splitTop(self.height - bottom)
  }
  
  func split(right:CGFloat) -> (left:CGRect, right:CGRect) {
    return split(left: self.width - right)
  }
  
  func split(left:CGFloat) -> (left:CGRect, right:CGRect) {
    let leftRect = CGRect(origin: self.origin, size: CGSize(width: CGFloat(left), height: size.height))
    let rightRect = CGRect(origin: self.origin.rightBy(left), size:CGSize(width: size.width - left, height: size.height))
    return (leftRect, rightRect)
  }
  
  func splitTopBottom() -> (top:CGRect, bottom:CGRect) {
    return splitTop(self.height / 2.0)
  }
  
  func splitLeftRight() -> (left:CGRect, right:CGRect) {
    return split(left:self.width / 2.0)
  }
  
  func splitFromRight(_ d:CGFloat) -> (left:CGRect, right:CGRect) {
    return self.split(left:size.width - d)
  }
  
  func with(width nw: CGFloat, height nh:CGFloat) -> CGRect {
    return CGRect(origin: origin, size: CGSize(width: nw, height: nh))
  }
  
  func with(height nh:CGFloat) -> CGRect {
    return CGRect(origin: origin, size: CGSize(width: width, height: nh))
  }
  
  func with(width nw:CGFloat) -> CGRect {
    return CGRect(origin: origin, size: CGSize(width: nw, height: height))
  }
  
  func with(x nx:CGFloat) -> CGRect {
    return CGRect(origin: CGPoint(x: nx, y: origin.y), size: size)
  }
  
  func with(y ny:CGFloat) -> CGRect {
    return CGRect(origin: CGPoint(x: origin.x, y: ny), size: size)
  }
  
  func withoutTop(_ d:CGFloat) -> CGRect {
    return CGRect(origin: origin.downBy(d), size: CGSize(width: width, height: height - d))
  }
  
  func withoutBottom(_ d:CGFloat) -> CGRect {
    return CGRect(origin: origin, size: CGSize(width: width, height: height - CGFloat(d)))
  }
  
  func withoutLeft(_ d:CGFloat) -> CGRect {
    return CGRect(origin: origin.rightBy(d), size: CGSize(width: width - d, height: height))
  }
  
  func withoutRight(_ d:CGFloat) -> CGRect {
    return CGRect(origin: origin, size: CGSize(width: width - CGFloat(d), height: height))
  }
  
  func align(_ elementSize:CGSize, _ vertical: VerticalAlignment, _ horizontal: HorizontalAlignment) -> CGRect {
    let top: CGFloat
    
    switch vertical {
    case .top: top = 0.0
    case .middle: top = self.height / 2.0 - elementSize.height / 2.0
    case .bottom: top = self.height - elementSize.height
    }
    
    let left: CGFloat
    
    switch horizontal {
    case .left: left = 0.0
    case .middle: left = self.width / 2.0 - elementSize.width / 2.0
    case .right: left = self.width - elementSize.width
    }
    
    return CGRect(origin: CGPoint(x: self.left + left, y: self.top + top), size: elementSize)
  }
  
  func resetOrigin() -> CGRect {
    return CGRect(origin: CGPoint.zero, size: self.size)
  }
}

public enum VerticalAlignment {
  case top
  case middle
  case bottom
}

public enum HorizontalAlignment {
  case left
  case middle
  case right
}

public func *(lhs: CGRect, rhs: CGFloat) -> CGRect {
  return CGRect(origin: lhs.origin * rhs, size: lhs.size * rhs)
}

public func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
  return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

public func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
  return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

public extension CGSize {
  func horizontallyCenteredIn(rect:CGRect) -> (left:CGFloat, right:CGFloat) {
    let midPoint = rect.midX
    let halfWidth = self.width / 2.0
    return (left:midPoint - halfWidth, right:midPoint + halfWidth)
  }
  
  func centeredIn(size: CGSize) -> CGRect {
    let x = (size.width - self.width) / 2
    let y = (size.height - self.height) / 2
    
    return CGRect(origin: CGPoint(x: x, y: y), size: self)
  }
  
  func shorterBy(h:CGFloat) -> CGSize {
    return CGSize(width: self.width, height: self.height - CGFloat(h))
  }
  
  func thinnerBy(w:CGFloat) -> CGSize {
    return CGSize(width: self.width - CGFloat(w), height: self.height)
  }
}

public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
  return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
  return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func -(lhs: CGPoint, rhs: CGSize) -> CGPoint {
  return CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
}

public extension CGPoint {
  func clockwise(radius:Double, theta: Double) -> CGPoint {
    let startAngle = Float(Double.pi * 2.0 * -0.25 + theta)
    
    let v = Double(sinf(startAngle)) * radius
    let h = Double(cosf(startAngle)) * radius
    
    let modp = CGPoint(x: h, y: v)
    
    return self + modp
  }
  
  func leftBy(_ d:CGFloat) -> CGPoint {
    return CGPoint(x: self.x - d, y: self.y)
  }
  
  func rightBy(_ d:CGFloat) -> CGPoint {
    return CGPoint(x: self.x + d, y: self.y)
  }
  
  func upBy(_ d:CGFloat) -> CGPoint {
    return CGPoint(x: self.x, y: self.y - d)
  }
  
  func downBy(_ d:CGFloat) -> CGPoint {
    return CGPoint(x: self.x, y: self.y + d)
  }
}
