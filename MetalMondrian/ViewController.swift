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
//  var texture: MTLTexture
  var sampler: MTLSamplerState
    
  var tesselator : Tesselator<FatVertex> = Tesselator()
  var geo: GeometryData<FatVertex>?
  var texture: Texture?
    
  
  public init(frame:CGRect, device:MTLDevice, metalLayer:CAMetalLayer) {
    self.device = device
    self.metalLayer = metalLayer
    
    
    self.pipeline = createPipeline(device: device)
    self.commandQueue = device.makeCommandQueue()!

    let image = UIImage(named: "mondrian_square.png")!
    self.texture = makeTexture(image: image.cgImage!, device:device)
   
    self.sampler = defaultSampler(device: device)!
    
    super.init(frame:frame)
    
    for v in fatTriangle {
        tesselator.push(v)
    }
    self.geo = tesselator.createGeometry(device: device)
    
    
    self.metalLayer.frame = self.layer.frame  // 5
    self.layer.addSublayer(metalLayer)
    
    displayLink = CADisplayLink(target: self, selector: #selector(PrimaryView.runLoop))
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
    guard let geoData = self.geo else { return }
    guard let drawable = metalLayer.nextDrawable() else { return }
//    print("render :D")
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
    renderPassDescriptor.colorAttachments[0].storeAction = .store
    
    let theta = NSDate().timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: tau)
    let rotation = getRotationAroundZ(Float(theta))
    
    let uniformBuffer = device.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: [])!
    uniformBuffer.contents().storeBytes(of: rotation, as: matrix_float4x4.self)
    
    let commandBuffer = commandQueue.makeCommandBuffer()!
    
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
    renderEncoder.setRenderPipelineState(pipeline)
    renderEncoder.setVertexBuffer(geoData.vertexBuffer, offset: 0, index: 0)
    renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
    
    renderEncoder.setFragmentSamplerState(self.sampler, index: 0)
    if let t = self.texture {
        renderEncoder.setFragmentTexture(t.texture, index: 0)
    }

    renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: geoData.vertexCount, instanceCount: 1)
    renderEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
