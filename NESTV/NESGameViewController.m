//
//  NESGameViewController.m
//  NESTV
//
//  Created by Conrad Kramer on 9/16/15.
//  Copyright © 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <nesemu2/nesemu2.h>
#import <GameController/GameController.h>

#import "NESGameViewController.h"

@implementation NESGameViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSURL *temporaryDirectoryURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"nesemu2"];
        NSURL *configURL = [temporaryDirectoryURL URLByAppendingPathComponent:@"nesemu2.cfg"];
        [[NSFileManager defaultManager] createDirectoryAtURL:temporaryDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createFileAtPath:configURL.path contents:nil attributes:nil];
        
        _emulator = [[NESEmulator alloc] initWithConfigurationURL:configURL dataDirectoryURL:temporaryDirectoryURL];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [self.view.layer addSublayer:self.emulator.layer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.emulator loadRomAtURL:[[NSBundle mainBundle] URLForResource:@"smb" withExtension:@"nes"]];
    
    // TODO: Handle controllers properly
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_emulator configureController:[[GCController controllers] firstObject] forPlayerAtIndex:GCControllerPlayerIndex1];
    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    CGSize size = CGSizeMake(256, 240);
    CGFloat scale = MIN(CGRectGetWidth(bounds) / size.width, CGRectGetHeight(bounds) / size.height);
    
    CALayer *layer = self.emulator.layer;
    layer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    layer.bounds = (CGRect){CGPointZero, CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(scale, scale))};
    layer.frame = CGRectIntegral(layer.frame);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.emulator start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.emulator pause];
}

@end
