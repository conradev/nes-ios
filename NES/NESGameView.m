//
//  NESGameView.m
//  NES
//
//  Created by Conrad Kramer on 5/30/15.
//  Copyright (c) 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <nesemu2/nesemu2.h>

#import "NESGameView.h"

@implementation NESGameView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithEmulator:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithEmulator:nil];
}

- (instancetype)initWithEmulator:(NESEmulator *)emulator {
    NSParameterAssert(emulator);
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _emulator = emulator;
        
        [self.layer addSublayer:emulator.layer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGSize size = CGSizeMake(256, 240);
    CGFloat scale = MIN(CGRectGetWidth(bounds) / size.width, CGRectGetHeight(bounds) / size.height);
    
    CALayer *layer = self.emulator.layer;
    layer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    layer.bounds = (CGRect){CGPointZero, CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(scale, scale))};
    layer.frame = CGRectIntegral(layer.frame);
}

@end
