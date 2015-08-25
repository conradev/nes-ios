//
//  NESEmulator.h
//  NES
//
//  Created by Conrad Kramer on 4/26/15.
//  Copyright (c) 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_OPTIONS(UInt8, NESControllerState) {
    NESControllerStateA =      (1 << 0),
    NESControllerStateB =      (1 << 1),
    NESControllerStateSelect = (1 << 2),
    NESControllerStateStart =  (1 << 3),
    NESControllerStateUp =     (1 << 4),
    NESControllerStateDown =   (1 << 5),
    NESControllerStateLeft =   (1 << 6),
    NESControllerStateRight =  (1 << 7),
};

@interface NESEmulator : NSObject

@property (nonatomic, readonly) NSURL *configurationUrl;
@property (nonatomic, readonly, getter=isRunning) BOOL running;
@property (nonatomic, readonly, getter=isPaused) BOOL paused;
@property (nonatomic, readonly) CALayer *layer;

@property (nonatomic) NESControllerState player1;
@property (nonatomic) NESControllerState player2;
@property (nonatomic) NESControllerState player3;
@property (nonatomic) NESControllerState player4;

- (instancetype)initWithConfigurationURL:(NSURL *)configurationURL dataDirectoryURL:(NSURL *)dataDirectoryURL NS_DESIGNATED_INITIALIZER;

- (void)loadRomAtURL:(NSURL *)romURL;
- (void)start;
- (void)stop;

- (void)pause;
- (void)unpause;

@end
