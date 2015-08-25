//
//  Shaders.metal
//  NES
//
//  Created by Conrad Kramer on 5/30/15.
//  Copyright (c) 2015 Kramer Software Productions, LLC. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

typedef struct vertex_data {
    float4 position [[position]];
    float2 texcoord;
} vertex_data;

vertex vertex_data nes_vertex(const device packed_float2* vertex_array [[ buffer(0) ]],
                              unsigned int vid [[ vertex_id ]]) {
    float2 texcoords[] = {
        {0, 1},
        {0, 0},
        {1, 1},
        {1, 0}
    };
    vertex_data out;
    out.position = float4(vertex_array[vid], 0.0, 1.0);
    out.texcoord = texcoords[vid];
    return out;
}

fragment half4 nes_fragment(vertex_data in [[ stage_in ]],
                            texture2d<float> texture [[ texture(0) ]]) {
    constexpr sampler nes_sampler(address::clamp_to_zero, filter::nearest);
    return half4(texture.sample(nes_sampler, in.texcoord));
}
