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
  let button: BasicButton = BasicButton()
  var modelButtons: [(BasicButton, StyleModel)] = []
  
  public init(frame:CGRect, canvas:CanvasView) {
    self.canvas = canvas
    super.init(frame:frame)
    self.addSubview(canvas)
    
    button.onTouchUpInside = { [weak self] in
      self?.toggleBlend()
    }
    self.addSubview(button)
    self.updateBlendButtonText()
    
    for styleModel in StyleModel.all {
      let styleButton = BasicButton()
      styleButton.onTouchUpInside = { [weak self] in
        self?.update(styleModel: styleModel)
      }
      styleButton.setTitle(styleModel.description, for: UIControlState.normal)
      self.addSubview(styleButton)
      modelButtons.append((styleButton, styleModel))
    }
    
    self.backgroundColor = Color.blue.uiColor
  }
  
  public func update(styleModel:StyleModel) {
    self.canvas.renderState.model = styleModel
    self.canvas.checkStylized()
  }
  
  public func toggleBlend() {
    self.canvas.renderState.blendMode = self.canvas.renderState.blendMode.next
    self.updateBlendButtonText()
  }
  
  public func updateBlendButtonText() {
    button.setTitle(self.canvas.renderState.blendMode.description, for: UIControlState.normal)
  }
  
  required public init?(coder aDecoder: NSCoder) { return nil }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    let (canvasRect, controls) = self.bounds.split(left: 720)
    
    canvas.frame = canvasRect.with(height: 720)
    
    let (blend, styles) = controls.split(left: 200)
    button.frame = blend.with(height: 100.0)
    
    for (i, (styleButton, _)) in self.modelButtons.enumerated() {
      styleButton.frame = styles.with(width: 200.0, height: 100.0).downBy(100.0 * CGFloat( i))
    }
  }
}

class ViewController: UIViewController {
  let model = FNSMosaic()
  
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
      
      let bitmap : Bitmap<RGBAPixel> = Bitmap(width: 720, height: 720, defaultPixel: RGBAPixel.opaqueWhite)

      let renderState = RenderState(drawing: bitmap)
      let renderContext = RenderContext(device: device)
      
      let stylizeQueue = DispatchQueue(label: "stylize", qos: .userInteractive, attributes: DispatchQueue.Attributes(rawValue: 0), autoreleaseFrequency: .workItem, target: nil)
      
      let canvas = CanvasView(frame: CGRect(x: 0, y: 0, width: 720, height: 720), renderState: renderState, renderContext: renderContext, metalLayer: metalLayer, stylizeQueue: stylizeQueue)
      
      self.view = CombinedView(frame: UIScreen.main.bounds, canvas: canvas)
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


