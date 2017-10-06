//
//  Constraint.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 6/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import Foundation
import UIKit

public struct Constraint {
  public static func completelyEqual(_ lhs:UIView, _ rhs: UIView) -> [NSLayoutConstraint] {
    return [
      lhs.leftAnchor.constraint(equalTo: rhs.leftAnchor),
      lhs.rightAnchor.constraint(equalTo: rhs.rightAnchor),
      lhs.topAnchor.constraint(equalTo: rhs.topAnchor),
      lhs.bottomAnchor.constraint(equalTo: rhs.bottomAnchor)
    ]
  }
}
