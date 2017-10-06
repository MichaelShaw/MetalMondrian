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
};

struct Uniforms {
    float4x4 ndcMatrix;
};

vertex VertexOut basic_vertex(
                              const device FatVertex* vertex_array [[ buffer(0) ]],
                              const device Uniforms& uniforms [[buffer(1)]],
                              unsigned int vid [[ vertex_id ]]) {
    
    FatVertex v = vertex_array[vid];
    
    VertexOut VertexOut;
    VertexOut.position = uniforms.ndcMatrix * float4(v.position,1);
    VertexOut.color = v.color;
    VertexOut.texture_coords = v.texture_coords;
    
    return VertexOut;
}

fragment float4 basic_fragment(VertexOut interpolated [[stage_in]],
                              texture2d<float>  tex2D     [[ texture(0) ]],
                              sampler           sampler2D [[ sampler(0) ]]) {
    float4 color = tex2D.sample(sampler2D, interpolated.texture_coords);
    return color; // half4(interpolated.color[0], interpolated.color[1], interpolated.color[2], interpolated.color[3]);
}


