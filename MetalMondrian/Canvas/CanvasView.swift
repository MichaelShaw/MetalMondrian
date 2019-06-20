//
//  CanvasView.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 13/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import UIKit
import Metal
import MetalKit

public struct StylizeVersion {
  public let drawingVersion: Int
  public let style: StyleModel
}

extension StylizeVersion : Equatable {
  
}

public func ==(lhs:StylizeVersion, rhs:StylizeVersion) -> Bool {
  
  return lhs.drawingVersion == rhs.drawingVersion && lhs.style == rhs.style
}

enum LoadedModel {
  case candy(FNSCandy)
  case feathers(FNSFeathers)
  case laMuse(FNSLaMuse)
  case mosaic(FNSMosaic)
  case theScream(FNSTheScream)
  case udnie(FNSUdnie)
}

public class CanvasView : UIView {
  var canvasState: CanvasState
  var renderContext : RenderContext
  
  var lastPoint: Point?
  
  var displayLink: CADisplayLink?
  
  let metalLayer : CAMetalLayer
  
  let stylizeQueue : DispatchQueue
  var styleModel : LoadedModel? = nil
  var styleStatus : StyleStatus = .idle
  var lastStyle: (StylizeVersion, Bitmap<RGBAPixel>)? = nil
  
  public init(frame:CGRect, canvasState: CanvasState, renderContext:RenderContext, metalLayer:CAMetalLayer, stylizeQueue: DispatchQueue) {
    self.canvasState = canvasState
    self.renderContext = renderContext
    self.metalLayer = metalLayer
    
    self.stylizeQueue = stylizeQueue
    
    super.init(frame:frame)
    
    
    metalLayer.frame = self.layer.frame  // 5
    self.layer.addSublayer(metalLayer)
    
    displayLink = CADisplayLink(target: self, selector: #selector(CanvasView.runLoop))
    displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
  }
  
  required public init?(coder aDecoder: NSCoder) { return nil }
  
  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      self.drawAt(point: touch.location(in: self))
    }
    
    
    super.touchesBegan(touches, with: event)
  }
  
  override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      self.drawAt(point: touch.location(in: self))
    }
    super.touchesMoved(touches, with: event)
  }
  
  override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      self.drawAt(point: touch.location(in: self))
    }
    super.touchesEnded(touches, with: event)
    lastPoint = nil
  }
  
  override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    lastPoint = nil
  }
  
  public func drawAt(point:CGPoint) {
    let point = Point(x: Int(point.x), y: Int(point.y))
    self.canvasState.draw(from: lastPoint, to: point)
    self.lastPoint = point
    self.checkStylized()
  }
  
  @objc public func runLoop() {
    autoreleasepool {
      self.render()
    }
  }
	
	func ensureLoaded(style:StyleModel) {
		switch (style, self.styleModel) {
		case (.candy, .some(.candy(_))): ()
		case (.feathers, .some(.feathers(_))): ()
		case (.laMuse, .some(.laMuse(_))): ()
		case (.mosaic, .some(.mosaic(_))): ()
		case (.theScream, .some(.theScream(_))):()
		case (.udnie, .some(.udnie(_))): ()
		default:
			let m : LoadedModel
			switch style {
			case .candy: m = .candy(FNSCandy())
			case .feathers: m = .feathers(FNSFeathers())
			case .laMuse: m = .laMuse(FNSLaMuse())
			case .mosaic: m = .mosaic(FNSMosaic())
			case .theScream: m = .theScream(FNSTheScream())
			case .udnie: m = .udnie(FNSUdnie())
			}
			self.styleModel = m
		}
	}
	
	func predict(pixelBuffer:CVPixelBuffer, model:LoadedModel) -> CVPixelBuffer {
		switch model {
		case .candy(let cr):
			return (try! cr.prediction(inputImage: pixelBuffer)).outputImage
		case .feathers(let model):
			return (try! model.prediction(inputImage: pixelBuffer)).outputImage
		case .laMuse(let model):
			return (try! model.prediction(inputImage: pixelBuffer)).outputImage
		case .mosaic(let model):
			return (try! model.prediction(inputImage: pixelBuffer)).outputImage
		case .theScream(let model):
			return (try! model.prediction(inputImage: pixelBuffer)).outputImage
		case .udnie(let model):
			return (try! model.prediction(inputImage: pixelBuffer)).outputImage
		}
	}
  
  func checkStylized() {
    let currentVersion = self.canvasState.stylizeVersion()
    
    switch styleStatus {
    case .idle:
      let run:Bool
      if let (lastVer, _) = self.lastStyle {
        run = lastVer != currentVersion
      } else {
        run = true
      }
	
      if run {
        print("run styleize :D")
        let imgToStyle = self.canvasState.drawing

        self.styleStatus = .running
        self.stylizeQueue.async {
          var bgraImage : Bitmap<BGRAPixel> = map(bmp: imgToStyle) { p in p.toBGRA }
          if let pb = createPixelBuffer(forBitmap:&bgraImage) {
			self.ensureLoaded(style: currentVersion.style)
			let prediction : CVPixelBuffer?
			if let m = self.styleModel {
				prediction = self.predict(pixelBuffer: pb, model: m)
			} else {
				prediction = nil
			}
			
            if let out = prediction {
              if let outBitmap = readBack(buffer:out, width: 720, height:720) {
                let rgbaImage : Bitmap<RGBAPixel> = map(bmp: outBitmap) { p in p.toRGBA }
                DispatchQueue.main.async {
                  print("main queue update version, bitmap, etc")
                  self.lastStyle = (currentVersion, rgbaImage)
                  self.styleStatus = .idle
                  // recheck
                  self.checkStylized()
                }
              } else {
                print("cant read output cv to bitmap")
              }
            }
          } else {
            print("couldnt create cv for input bitmap")
          }
        }
      }
    case .running:
      ()
      // do nothing, already running .. we'll recur on completion to check for whether we should update again
    }
  }
  
  public func render() {
    guard let drawable = metalLayer.nextDrawable() else { return }
    
    self.renderContext.render(drawable: drawable, state: self.canvasState, style: &self.lastStyle)
  }
}

