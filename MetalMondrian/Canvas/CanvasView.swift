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

public class CanvasView : UIView {
  var renderState: RenderState
  var renderContext : RenderContext
  
  var displayLink: CADisplayLink?
  
  let metalLayer : CAMetalLayer
  
  let stylizeQueue : DispatchQueue
  let styleModel = FNSMosaic()
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
  }
  
  override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
  }
  
  public func drawAt(point:CGPoint) {
    self.renderState.drawAt(point: point)
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
        let model = self.styleModel
        
        self.styleStatus = .running
        self.stylizeQueue.async {
          if let pb = createPixelBuffer(forBitmap:&imgToStyle) {
            let out = try! model.prediction(inputImage: pb)
            
            if let outBitmap = readBack(buffer:out.outputImage, width: 720, height:720) {
              DispatchQueue.main.async {
                print("main queue update version, bitmap, etc")
                self.lastStyle = (currentVersion, outBitmap)
                self.styleStatus = .idle
                // recheck
              }
            } else {
              print("cant read output cv to bitmap")
            }
            
          } else {
            print("couldnt create cv for input bitmap")
          }
          
        }
      }
      
      
      
    case .running:
      ()
      // do nothing, already running
    }
  }
  
  public func render() {
    guard let drawable = metalLayer.nextDrawable() else { return }
    
    self.renderContext.render(drawable: drawable, state: self.renderState, style: &self.lastStyle)
  }
}

