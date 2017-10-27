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
  var colorButtons: [(BasicButton, Color)] = []
  
  public init(frame:CGRect, canvas:CanvasView) {
    self.canvas = canvas
    super.init(frame:frame)
    self.addSubview(canvas)
    
    button.backgroundColor = Color.grays[6].uiColor
    button.layer.cornerRadius = 5.0
    button.clipsToBounds = true
    
    button.onTouchUpInside = { [weak self] in
      self?.toggleBlend()
    }
    self.addSubview(button)
    self.updateBlendButtonText()
    
    for color in Color.pico8 {
      let colorButton = BasicButton()
      colorButton.layer.cornerRadius = 5.0
      colorButton.clipsToBounds = true
      colorButton.onTouchUpInside = { [weak self] in
        self?.update(color: color)
      }
      colorButton.backgroundColor = color.uiColor
      self.addSubview(colorButton)
      self.colorButtons.append((colorButton, color))
    }
    
    for styleModel in StyleModel.all {
      let styleButton = BasicButton()
      
      styleButton.layer.cornerRadius = 5.0
      styleButton.clipsToBounds = true

      styleButton.backgroundColor = Color.black.uiColor
      
      styleButton.onTouchUpInside = { [weak self] in
        self?.update(styleModel: styleModel)
      }
      let image: UIImage
      switch styleModel {
      case .candy: image = #imageLiteral(resourceName: "candy.thumb.jpg")
      case .feathers: image = #imageLiteral(resourceName: "feathers.thumb.jpg")
      case .laMuse: image = #imageLiteral(resourceName: "la_muse.thumb.jpg")
      case .mosaic: image = #imageLiteral(resourceName: "mosaic.thumb.jpg")
      case .theScream: image = #imageLiteral(resourceName: "the_scream.thumb.jpg")
      case .udnie: image = #imageLiteral(resourceName: "udnie.thumb.jpg")
      }
      
      styleButton.setImage(image, for: UIControlState.normal)
//      styleButton.setTitle(styleModel.description, for: )
      self.addSubview(styleButton)
      modelButtons.append((styleButton, styleModel))
    }
    
    self.backgroundColor = Color.grays[3].uiColor
    
    self.updateSelected()
  }
  
  public func update(color:Color) {
    self.canvas.canvasState.color = color.toRgb
    self.updateSelected()
  }
  
  public func update(styleModel:StyleModel) {
    self.canvas.canvasState.model = styleModel
    self.canvas.checkStylized()
    self.updateSelected()
  }
  
  public func toggleBlend() {
    self.canvas.canvasState.blendMode = self.canvas.canvasState.blendMode.next
    self.updateBlendButtonText()
    self.updateSelected()
  }
  
  public func updateBlendButtonText() {
    button.setTitle(self.canvas.canvasState.blendMode.description, for: UIControlState.normal)
  }
  
  public func updateSelected() {
    for (button, style) in modelButtons {
      if style == self.canvas.canvasState.model {
        button.layer.borderColor = Color.white.cgColor
        button.layer.borderWidth = 8.0
      } else {
        button.layer.borderColor = nil
        button.layer.borderWidth = 0.0
      }
    }
    
    for (button, color) in colorButtons {
      if color.toRgb == self.canvas.canvasState.color {
        button.layer.borderColor = Color.white.cgColor
        button.layer.borderWidth = 8.0
      } else {
        button.layer.borderColor = nil
        button.layer.borderWidth = 0.0
      }
    }
  }
  
  required public init?(coder aDecoder: NSCoder) { return nil }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    let colorPadding : CGFloat = 5.0
    let stylePadding : CGFloat = 20.0
    
    
    let (paintingRect, controls) = self.bounds.padded(by: 40.0).split(left: 720)
    
    let (canvasRect, colorRect) = paintingRect.splitTop(720)
    
    canvas.frame = canvasRect
    
    let (colors, blending) = colorRect.downBy(20.0).split(right: 140.0)
    
    let swatchSize : CGFloat = 65.0
    
    for (i, (colorButton, _)) in self.colorButtons.enumerated() {
      colorButton.frame = colors.with(width: swatchSize, height: swatchSize).offsetBy(dx: CGFloat(i % 8) * (colorPadding + swatchSize), dy: CGFloat(i / 8) * (colorPadding + swatchSize))
    }
    
    button.frame = blending.with(height: swatchSize * 2.0 + colorPadding)
    
    let stylesRect = controls.insetBy(dx: stylePadding, dy: 0.0)
    
    for (i, (styleButton, _)) in self.modelButtons.enumerated() {
      let w : CGFloat = 256
      let h : CGFloat = 205.0
      
      styleButton.frame = stylesRect.with(width: w, height: h).offsetBy(dx: CGFloat(i % 2) * (w + stylePadding), dy: CGFloat(i / 2) * (h + stylePadding) )
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
      
      let bitmap : Bitmap<RGBAPixel> = bitmapWithDefault(width: 720, height: 720, defaultPixel: Color.picoWhitish.toRgb)

      let canvasState = CanvasState(drawing: bitmap)
      let renderContext = RenderContext(device: device)
      
      let stylizeQueue = DispatchQueue(label: "stylize", qos: .userInteractive, attributes: DispatchQueue.Attributes(rawValue: 0), autoreleaseFrequency: .workItem, target: nil)
      
      let canvas = CanvasView(frame: CGRect(x: 0, y: 0, width: 720, height: 720), canvasState: canvasState, renderContext: renderContext, metalLayer: metalLayer, stylizeQueue: stylizeQueue)
      
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


