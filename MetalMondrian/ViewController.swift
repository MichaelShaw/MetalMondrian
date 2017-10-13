//
//  ViewController.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 6/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import UIKit
import GLKit
import Metal

public class CombinedView : UIView {
  let canvas: CanvasView
  
  public init(frame:CGRect, canvas:CanvasView) {
    self.canvas = canvas
    super.init(frame:frame)
    self.addSubview(canvas)
    self.backgroundColor = Color.blue.uiColor
  }
  
  required public init?(coder aDecoder: NSCoder) { return nil }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    canvas.frame = self.bounds.with(width: 720, height: 720)
  }
}

class ViewController: UIViewController {
  public let renderState = RenderState(drawing: Bitmap(width: 720, height: 720))

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func loadView() {
    if let device = MTLCreateSystemDefaultDevice() {
      let metalLayer = CAMetalLayer()
      metalLayer.device = device
      metalLayer.pixelFormat = .bgra8Unorm
      metalLayer.framebufferOnly = true
      
      let bitmap : Bitmap<RGBAPixel> = Bitmap(width: 720, height: 720)
      
      for x in 0..<720 {
        for y in 0..<720 {
          let xr = UInt8(Double(x) / 720.0 * 255.0)
          let yr = UInt8(Double(y) / 720.0 * 255.0)
          
          bitmap.set(x: x, y:y, pixel: RGBAPixel(r: xr, g:yr, b: 0, a: 255))
        }
      }
      
      let renderState = RenderState(drawing: bitmap)
      let renderContext = RenderContext(device: device)
      
      let canvas = CanvasView(frame: CGRect(x: 0, y: 0, width: 720, height: 720), renderState: renderState, renderContext: renderContext, metalLayer: metalLayer)
      
      self.view = CombinedView(frame: UIScreen.main.bounds, canvas: canvas)
      self.view.backgroundColor = Color.green.uiColor
    } else {
      self.view = UIView(frame:  UIScreen.main.bounds)
      self.view.backgroundColor = Color.red.uiColor
    }
    
    self.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
  }
 
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

let pi = Double.pi
let tau = pi * 2


