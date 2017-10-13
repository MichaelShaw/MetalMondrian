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

class CanvasView : UIView {
  var renderState: RenderState
  var renderContext : RenderContext
  
  var displayLink: CADisplayLink?
  
  let metalLayer : CAMetalLayer
  
  var texture: Texture?
  
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
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("began -> \(touches)")
    super.touchesBegan(touches, with: event)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    print("moved -> \(touches)")
    super.touchesMoved(touches, with: event)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("ended -> \(touches)")
    super.touchesEnded(touches, with: event)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("cancelled -> \(touches)")
    super.touchesCancelled(touches, with: event)
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    print("layout subviews within my bounds \(self.bounds)")
  }
  
  @objc public func runLoop() {
    autoreleasepool {
      self.render()
    }
  }
  
  public func render() {
//    guard let geoData = self.geo else { return }
    guard let drawable = metalLayer.nextDrawable() else { return }
    
    self.renderContext.render(drawable: drawable)
    

  }
}

