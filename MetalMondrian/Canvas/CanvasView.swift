//
//  CanvasView.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 13/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import UIKit
import Metal
import MetalKit

public struct StylizeVersion {
  public let drawingVersion: Int
  public let style: StyleModel
}

extension StylizeVersion : Equatable {
  
}

public func ==(lhs:StylizeVersion, rhs:StylizeVersion) -> Bool {
  
  return lhs.drawingVersion == rhs.drawingVersion && lhs.style == rhs.style
}

enum LoadedModel {
  case candy(FNSCandy)
  case feathers(FNSFeathers)
  case laMuse(FNSLaMuse)
  case mosaic(FNSMosaic)
  case theScream(FNSTheScream)
  case udnie(FNSUdnie)
}

public class CanvasView : UIView {
  var renderState: RenderState
  var renderContext : RenderContext
  
  var lastPoint: Point?
  
  var displayLink: CADisplayLink?
  
  let metalLayer : CAMetalLayer
  
  let stylizeQueue : DispatchQueue
  var styleModel : LoadedModel? = nil
  var styleStatus : StyleStatus = .idle
  var lastStyle: (StylizeVersion, Bitmap<RGBAPixel>)? = nil
  
  public init(frame:CGRect, renderState: RenderState, renderContext:RenderContext, metalLayer:CAMetalLayer, stylizeQueue: DispatchQueue) {
    self.renderState = renderState
    self.renderContext = renderContext
    self.metalLayer = metalLayer
    
    self.stylizeQueue = stylizeQueue
    
    super.init(frame:frame)
    
    
    metalLayer.frame = self.layer.frame  // 5
    self.layer.addSublayer(metalLayer)
    
    displayLink = CADisplayLink(target: self, selector: #selector(CanvasView.runLoop))
    displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
  }
  
  required public init?(coder aDecoder: NSCoder) { return nil }
  
  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      self.drawAt(point: touch.location(in: self))
    }
    
    
    super.touchesBegan(touches, with: event)
  }
  
  override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      self.drawAt(point: touch.location(in: self))
    }
    super.touchesMoved(touches, with: event)
  }
  
  override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      self.drawAt(point: touch.location(in: self))
    }
    super.touchesEnded(touches, with: event)
    lastPoint = nil
  }
  
  override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    lastPoint = nil
  }
  
  public func drawAt(point:CGPoint) {
    let point = Point(x: Int(point.x), y: Int(point.y))
    self.renderState.draw(from: lastPoint, to: point)
    self.lastPoint = point
    self.checkStylized()
  }
  
  @objc public func runLoop() {
    autoreleasepool {
      self.render()
    }
  }
  
  func checkStylized() {
    let currentVersion = self.renderState.stylizeVersion()
    
    switch styleStatus {
    case .idle:
      let run:Bool
      if let (lastVer, _) = self.lastStyle {
        run = lastVer != currentVersion
      } else {
        run = true
      }
      
      if run {
        print("run styleize :D")
        var imgToStyle = self.renderState.drawing
        
        self.styleStatus = .running
        self.stylizeQueue.async {
          if let pb = createPixelBuffer(forBitmap:&imgToStyle) {
            // check correct model loaded
            switch (currentVersion.style, self.styleModel) {
            case (.candy, .some(.candy(_))): ()
            case (.feathers, .some(.feathers(_))): ()
            case (.laMuse, .some(.laMuse(_))): ()
            case (.mosaic, .some(.mosaic(_))): ()
            case (.theScream, .some(.theScream(_))):()
            case (.udnie, .some(.udnie(_))): ()
            default:
              switch currentVersion.style {
              case .candy: self.styleModel = .some(.candy(FNSCandy()))
              case .feathers: self.styleModel = .some(.feathers(FNSFeathers()))
              case .laMuse: self.styleModel = .some(.laMuse(FNSLaMuse()))
              case .mosaic: self.styleModel = .some(.mosaic(FNSMosaic()))
              case .theScream: self.styleModel = .some(.theScream(FNSTheScream()))
              case .udnie: self.styleModel = .some(.udnie(FNSUdnie()))
              }
            }
            
            
            let prediction : CVPixelBuffer?
            if let m = self.styleModel {
              switch m {
              case .candy(let model):
                prediction = try! model.prediction(inputImage: pb).outputImage
              case .feathers(let model):
                prediction = try! model.prediction(inputImage: pb).outputImage
              case .laMuse(let model):
                prediction = try! model.prediction(inputImage: pb).outputImage
              case .mosaic(let model):
                prediction = try! model.prediction(inputImage: pb).outputImage
              case .theScream(let model):
                prediction = try! model.prediction(inputImage: pb).outputImage
              case .udnie(let model):
                prediction = try! model.prediction(inputImage: pb).outputImage
              }
            } else {
              prediction = nil
            }
            
            if let out = prediction {
              if let outBitmap = readBack(buffer:out, width: 720, height:720) {
                DispatchQueue.main.async {
                  print("main queue update version, bitmap, etc")
                  self.lastStyle = (currentVersion, outBitmap)
                  self.styleStatus = .idle
                  // recheck
                  self.checkStylized()
                }
              } else {
                print("cant read output cv to bitmap")
              }
            }
          } else {
            print("couldnt create cv for input bitmap")
          }
        }
      }
    case .running:
      ()
      // do nothing, already running .. we'll recur on completion to check for whether we should update again
    }
  }
  
  public func render() {
    guard let drawable = metalLayer.nextDrawable() else { return }
    
    self.renderContext.render(drawable: drawable, state: self.renderState, style: &self.lastStyle)
  }
}

