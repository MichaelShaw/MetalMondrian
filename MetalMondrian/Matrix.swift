//
//  Matrix.swift
//  MetalMondrian
//
//  Created by Michael Shaw on 6/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

import MetalKit

func getRotationAroundZ(_ radians : Float) -> matrix_float4x4 {
    var m : matrix_float4x4 = matrix_identity_float4x4;
    
    m.columns.0.x = cos(radians);
    m.columns.0.y = sin(radians);
    
    m.columns.1.x = -sin(radians);
    m.columns.1.y = cos(radians);
    
    return m;
}
