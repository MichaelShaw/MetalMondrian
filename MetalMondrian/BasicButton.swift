//
//  BasicButton.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 13/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//


import UIKit

open class BasicButton : UIButton {
  public var onTouchUpInside : (() -> ())? = nil
  
  public init() {
    super.init(frame: CGRect.zero)
    self.addTarget(self, action: #selector(BasicButton.touchUpInside), for: .touchUpInside)
  }
  
  @objc public func touchUpInside() {
    if let otu = self.onTouchUpInside {
      otu()
    }
  }
  
  required public init?(coder aDecoder: NSCoder) { return nil }
}
