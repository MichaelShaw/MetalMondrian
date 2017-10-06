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

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func loadView() {
    if let device = MTLCreateSystemDefaultDevice() {
      let metalLayer = CAMetalLayer()          // 1
      metalLayer.device = device           // 2
      metalLayer.pixelFormat = .bgra8Unorm // 3
      metalLayer.framebufferOnly = true    // 4
      
      self.view = PrimaryView(frame: UIScreen.main.bounds, device: device, metalLayer: metalLayer)
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

class PrimaryView : UIView {
  var device: MTLDevice
  var metalLayer: CAMetalLayer
  var pipeline: MTLRenderPipelineState
  var commandQueue: MTLCommandQueue
  var displayLink: CADisplayLink?
  
  var tesselator : Tesselator<ColoredVertex> = Tesselator()
  var geo: GeometryData<ColoredVertex>?
  
  public init(frame:CGRect, device:MTLDevice, metalLayer:CAMetalLayer) {
    self.device = device
    self.metalLayer = metalLayer
    
    
    self.pipeline = createPipeline(device: device)
    self.commandQueue = device.makeCommandQueue()!
//    print("vertex buffer -> \(vertexBuffer)")
//    print("pipeline -> \(pipeline)")
    
    
    
    super.init(frame:frame)
    
    for p in coloredTrianglePositions {
        tesselator.push(p)
    }
    self.geo = tesselator.createGeometry(device: device)
    
    
    self.metalLayer.frame = self.layer.frame  // 5
    self.layer.addSublayer(metalLayer)
    
    displayLink = CADisplayLink(target: self, selector: #selector(PrimaryView.runLoop))
    displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
  }
  
  required public init?(coder aDecoder: NSCoder) { return nil }
  
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
    guard let geoData = self.geo else { return }
    guard let drawable = metalLayer.nextDrawable() else { return }
    print("render :D")
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
    renderPassDescriptor.colorAttachments[0].storeAction = .store
    
    let theta = NSDate().timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: tau)
    var rotation = getRotationAroundZ(Float(theta))
    
    let uniformBuffer = device.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: [])!
    let bufferPointer = uniformBuffer.contents().storeBytes(of: rotation, as: matrix_float4x4.self)
        // .storeBytes(of: rotation, as: [Float])
    
  
    
    
//    memcpy(bufferPointer, rotation, MemoryLayout<Float>.size * 16)
    
    
    let commandBuffer = commandQueue.makeCommandBuffer()!
    
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
    renderEncoder.setRenderPipelineState(pipeline)
    renderEncoder.setVertexBuffer(geoData.vertexBuffer, offset: 0, index: 0)
    renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
    renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: geoData.vertexCount, instanceCount: 1)
    renderEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
