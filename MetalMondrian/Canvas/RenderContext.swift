//
//  RenderContext.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 13/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import Metal
import UIKit
import MetalKit

public class RenderContext {
  var device: MTLDevice
  var pipeline: MTLRenderPipelineState
  var commandQueue: MTLCommandQueue
  
  //  var texture: MTLTexture
  var sampler: MTLSamplerState
  
  var tesselator : Tesselator<FatVertex> = Tesselator()
  var geo: GeometryData<FatVertex>?
  
  var drawTexture: Texture?
  var drawTextureVersion : Int = -1
  var stylizedTexture: Texture?
  var stylizedTextureVersion: StylizeVersion = StylizeVersion(drawingVersion: -1, style: StyleModel.laMuse)
  
  public init(device:MTLDevice) {
    self.device = device
    self.pipeline = createPipeline(device: device)
    self.commandQueue = device.makeCommandQueue()!
    
    self.sampler = defaultSampler(device: device)!
    
    for v in fatSquare() {
      tesselator.push(v)
    }
    
    self.geo = tesselator.createGeometry(device: device)
  }
  
  public func render(drawable:CAMetalDrawable, state:RenderState, style: inout (StylizeVersion, Bitmap<RGBAPixel>)?) {
    
    guard let geoData = self.geo else { return }
    
    if state.drawingVersion != self.drawTextureVersion || self.drawTexture == nil {
      self.drawTexture = makeTexture(bitmap: state.drawing, device: device)
      self.drawTextureVersion = state.drawingVersion
    }
    
    if let (styleVersion, styleBitmap) = style, styleVersion != self.stylizedTextureVersion {
      print("style up")
      self.stylizedTexture = makeTexture(bitmap: styleBitmap, device: device)
      self.stylizedTextureVersion = styleVersion
    }
    
      //    print("render :D")
      let renderPassDescriptor = MTLRenderPassDescriptor()
      renderPassDescriptor.colorAttachments[0].texture = drawable.texture
      renderPassDescriptor.colorAttachments[0].loadAction = .clear
      renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
      renderPassDescriptor.colorAttachments[0].storeAction = .store
  
//      let theta = NSDate().timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: tau)
//      let rotation = getRotationAroundZ(Float(theta))
    
      let transform = matrix_identity_float4x4
    
      let uniformBuffer = device.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: [])!
      uniformBuffer.contents().storeBytes(of: transform, as: matrix_float4x4.self)
  
      let commandBuffer = commandQueue.makeCommandBuffer()!
  
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
      renderEncoder.setRenderPipelineState(pipeline)
      renderEncoder.setVertexBuffer(geoData.vertexBuffer, offset: 0, index: 0)
      renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
    
      renderEncoder.setFragmentSamplerState(self.sampler, index: 0)
    
      renderEncoder.setFragmentTexture(self.drawTexture!.texture, index: 0)
    if let st = self.stylizedTexture {
      renderEncoder.setFragmentTexture(st.texture, index: 1)
//      renderEncoder.setFragment
    }
    
    
  
      renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: geoData.vertexCount, instanceCount: 1)
      renderEncoder.endEncoding()
  
      commandBuffer.present(drawable)
      commandBuffer.commit()
  }
}



