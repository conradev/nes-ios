//
//  NESGameView.h
//  NES
//
//  Created by Conrad Kramer on 5/30/15.
//  Copyright (c) 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NESEmulator;

@interface NESGameView : UIView

@property (nonatomic, readonly) NESEmulator *emulator;

- (instancetype)initWithEmulator:(NESEmulator *)emulator NS_DESIGNATED_INITIALIZER;

@end
