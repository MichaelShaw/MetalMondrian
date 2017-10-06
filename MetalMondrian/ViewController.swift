//
//  ViewController.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 6/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import UIKit
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

let triangleVertices : [Float] = [
  0.0, 1.0, 0.0,
  -1.0, -1.0, 0.0,
  1.0, -1.0, 0.0
]

func createPipeline(device:MTLDevice) -> MTLRenderPipelineState {
  let lib = device.makeDefaultLibrary()!
  
  let pipelineDescription = MTLRenderPipelineDescriptor()
  pipelineDescription.vertexFunction = lib.makeFunction(name: "basic_vertex")
  pipelineDescription.fragmentFunction = lib.makeFunction(name: "basic_fragment")
  pipelineDescription.colorAttachments[0].pixelFormat = .bgra8Unorm
  
  return try! device.makeRenderPipelineState(descriptor: pipelineDescription)
}

class PrimaryView : UIView {
  var device: MTLDevice
  var metalLayer: CAMetalLayer
  var vertexBuffer: MTLBuffer
  var pipeline: MTLRenderPipelineState
  var commandQueue: MTLCommandQueue
  var displayLink: CADisplayLink?
  
  public init(frame:CGRect, device:MTLDevice, metalLayer:CAMetalLayer) {
    self.device = device
    self.metalLayer = metalLayer
    
    let dataSize = triangleVertices.count * MemoryLayout.size(ofValue: triangleVertices[0])
    self.vertexBuffer = device.makeBuffer(bytes: triangleVertices, length: dataSize, options: [])!
    self.pipeline = createPipeline(device: device)
    self.commandQueue = device.makeCommandQueue()!
//    print("vertex buffer -> \(vertexBuffer)")
//    print("pipeline -> \(pipeline)")
    
    super.init(frame:frame)
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
    
    guard let drawable = metalLayer.nextDrawable() else { return }
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
    
    let commandBuffer = commandQueue.makeCommandBuffer()!
    
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
    renderEncoder.setRenderPipelineState(pipeline)
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
    renderEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
