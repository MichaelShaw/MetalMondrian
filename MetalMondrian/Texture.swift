//
//  Texture.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 6/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import Metal
import UIKit


public struct Texture {
    let texture: MTLTexture
    let descriptor: MTLTextureDescriptor
}

func upload(bitmap:Bitmap<RGBAPixel>, toTexture texture:MTLTexture) {
  let region = MTLRegionMake2D(0, 0, bitmap.width, bitmap.height)
  
  let rowBytes = bitmap.width * RGBAPixel.bytes
  
  bitmap.storage.withUnsafeBytes { (u8Ptr: UnsafeRawBufferPointer) in
    let ptr = u8Ptr.baseAddress!
    texture.replace(region: region, mipmapLevel: 0, withBytes: ptr, bytesPerRow: Int(rowBytes))
  }
}

func upload(image:CGImage, toTexture texture:MTLTexture) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let width = image.width
    let height = image.height
    
    let bytesPerPixel = 4
    let bitsPerComponent = 8 // why was it 4 ....
    let rowBytes = width * bytesPerPixel
    
    let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: rowBytes, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    let bounds = CGRect(x: 0, y: 0, width: Int(width), height: Int(height))
    context.clear(bounds)
    context.draw(image, in: bounds)
  
    let region = MTLRegionMake2D(0, 0, width, height)
  
    texture.replace(region: region, mipmapLevel: 0, withBytes: context.data!, bytesPerRow: Int(rowBytes))
}

func makeTexture(bitmap:Bitmap<RGBAPixel>, device:MTLDevice) -> Texture {
  let width = bitmap.width
  let height = bitmap.height
  
  let texDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.rgba8Unorm, width: width, height: height, mipmapped: false)
  
  let tex = device.makeTexture(descriptor: texDescriptor)!
  
  upload(bitmap: bitmap, toTexture: tex)
  
  return Texture(texture: tex, descriptor: texDescriptor)
}

func makeTexture(image: CGImage, device:MTLDevice) -> Texture {
    let width = image.width
    let height = image.height
    
    let texDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.rgba8Unorm, width: width, height: height, mipmapped: false)
    
    let tex = device.makeTexture(descriptor: texDescriptor)!
    
    upload(image: image, toTexture: tex)
    
    return Texture(texture: tex, descriptor: texDescriptor)
}

func defaultSampler(device: MTLDevice) -> MTLSamplerState? {
    let sampler = MTLSamplerDescriptor()
    sampler.minFilter             = MTLSamplerMinMagFilter.nearest
    sampler.magFilter             = MTLSamplerMinMagFilter.nearest
    sampler.mipFilter             = MTLSamplerMipFilter.nearest
    sampler.maxAnisotropy         = 1
    sampler.sAddressMode          = MTLSamplerAddressMode.clampToEdge
    sampler.tAddressMode          = MTLSamplerAddressMode.clampToEdge
    sampler.rAddressMode          = MTLSamplerAddressMode.clampToEdge
    sampler.normalizedCoordinates = true
    sampler.lodMinClamp           = 0
    sampler.lodMaxClamp           = Float.greatestFiniteMagnitude
    return device.makeSamplerState(descriptor: sampler)
}
