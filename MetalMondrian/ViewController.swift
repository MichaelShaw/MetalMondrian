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
      self.view.backgroundColor = Color.green.uiColor
    } else {
      self.view = UIView(frame:  UIScreen.main.bounds)
      self.view.backgroundColor = Color.red.uiColor
    }
    
    self.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
  }
 
  override func viewDidLoad() {
    super.viewDidLoad()
//    let image
//    let imageView = UIImageView()
//    imageView.frame = self.view.bounds
//    print("giving image view bounds -> \(self.view.bounds)")
    
//    let bmp = #imageLiteral(resourceName: "mondrian_square.png")
//    if let cgImage = bmp.cgImage {
//      if let pb = pixelBuffer(forImage: cgImage) {
//        let pred = try! model.prediction(inputImage: pb)
////        let outBitmap = readBack(buffer:pred.outputImage, width: 720, height:720)
//        print("we have an out bitmap!")
//        if let outUIImage = uiImageFor(buffer: pred.outputImage) {
//          print("assigning image :D")
//          imageView.image = outUIImage
//        } else {
//          print("couldnt convert that cv")
//        }
//
//      } else {
//        print("no pb")
//      }
//    } else {
//      print("no cgimage :-/")
//    }
//
//    self.view.addSubview(imageView)
  }
}

let pi = Double.pi
let tau = pi * 2


