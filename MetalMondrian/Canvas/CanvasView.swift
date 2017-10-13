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

public class CanvasView : UIView {
  var renderState: RenderState
  var renderContext : RenderContext
  
  var displayLink: CADisplayLink?
  
  let metalLayer : CAMetalLayer

  public init(frame:CGRect, renderState: RenderState, renderContext:RenderContext, metalLayer:CAMetalLayer) {
    self.renderState = renderState
    self.renderContext = renderContext
    self.metalLayer = metalLayer
    
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
  }
  
  @objc public func runLoop() {
    autoreleasepool {
      self.render()
    }
  }
  
  public func render() {
    guard let drawable = metalLayer.nextDrawable() else { return }
    
    self.renderContext.render(drawable: drawable, state: self.renderState)
  }
}

