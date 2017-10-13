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
      
      let renderState = RenderState(drawing: Bitmap(width: 720, height: 720))
      let renderContext = RenderContext(device: device)
      
      self.view = CanvasView(frame: UIScreen.main.bounds, renderState: renderState, renderContext: renderContext, metalLayer: metalLayer)
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


