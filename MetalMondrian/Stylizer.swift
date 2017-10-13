//
//  Stylizer.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 13/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import CoreML
import UIKit


func uiImageFor(buffer pixelBuffer:CVPixelBuffer) -> UIImage? {
  let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
  
  let context = CIContext()
  
  if let imageRef = context.createCGImage(ciImage, from: CGRect(origin: CGPoint.zero, size: CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer)))) {
    let uiImage = UIImage(cgImage: imageRef)
    return uiImage
  } else {
    return nil
  }
}

func pixelBuffer(forImage image:CGImage) -> CVPixelBuffer? {
  let frameSize = CGSize(width: image.width, height: image.height)
  
  var pixelBuffer:CVPixelBuffer? = nil
  let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
  
  if status != kCVReturnSuccess {
    return nil
  }
  
  CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
  let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
  let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
  let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
  let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
  
  context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
  
  CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
  
  return pixelBuffer
  
}

func createPixelBuffer(forBitmap bitmap:inout Bitmap<RGBAPixel>) -> CVPixelBuffer? {
  var pixelBuffer:CVPixelBuffer? = nil
  bitmap.storage.withUnsafeMutableBytes { mt in
    let bp = mt.baseAddress!
    
    let bytesPerRow = bitmap.width * RGBAPixel.bytes
    let bytes = bitmap.pixels * RGBAPixel.bytes
    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(bitmap.width), Int(bitmap.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
    
    if status == kCVReturnSuccess {
      CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
      memcpy(data, bp, bytes)
      CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    } else {
      pixelBuffer = nil
    }
  }
  return pixelBuffer
}

func readBack(buffer:CVPixelBuffer, width: Int, height:Int) -> Bitmap<RGBAPixel>? {
  var bitmap : Bitmap<RGBAPixel>? = nil
  let pixels = width * height
  CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
  if let baseAddress = CVPixelBufferGetBaseAddress(buffer) {
    let raw = baseAddress.bindMemory(to:RGBAPixel.self, capacity: width * height)
    var bmp = Bitmap(width: width, height: height, defaultPixel: RGBAPixel.opaqueBlack)
    for i in 0..<pixels {
      bmp.storage[i] = raw[i]
    }
    bitmap = bmp
  } else {
    print("no base address :-(")
  }

  CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
  return bitmap
}


