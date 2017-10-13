//
//  Shaders.metal
//  MetalMondrian
//
//  Created by Michael Shaw on 6/10/17.
//  Copyright © 2017 Cosmic Teapot. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct FatVertex {
    packed_float3 position;
    packed_float2 texture_coords;
    packed_float4 color;
};

struct VertexOut {
    float4 position [[position]];
    float2 texture_coords;
    float4 color;
    float style;
};

struct Uniforms {
    float4x4 ndcMatrix;
  
};

vertex VertexOut basic_vertex(
                              const device FatVertex* vertex_array [[ buffer(0) ]],
                              const device Uniforms& uniforms [[buffer(1)]],
                              const device float* style  [[ buffer(2) ]],
                              unsigned int vid [[ vertex_id ]]) {
    
    FatVertex v = vertex_array[vid];
    
    VertexOut VertexOut;
    VertexOut.position = uniforms.ndcMatrix * float4(v.position,1);
    VertexOut.color = v.color;
    VertexOut.texture_coords = v.texture_coords;
    VertexOut.style = *style;
    
    return VertexOut;
}

fragment float4 basic_fragment(VertexOut interpolated [[stage_in]],
                              texture2d<float>  drawing     [[ texture(0) ]],
                              texture2d<float>  stylized     [[ texture(1) ]],
                              sampler           sampler2D [[ sampler(0) ]]) {
    float4 drawing_color = drawing.sample(sampler2D, interpolated.texture_coords);
    float4 stylized_color = stylized.sample(sampler2D, interpolated.texture_coords);
  
    return mix(drawing_color, stylized_color, interpolated.style); 
}


