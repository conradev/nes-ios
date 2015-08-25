//
//  NESGameViewController.m
//  NES
//
//  Created by Conrad Kramer on 6/21/15.
//  Copyright © 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <nesemu2/NESEmulator.h>

#import "NESGameViewController.h"

@interface NESGameViewController ()

@property (nonatomic, readonly) NESEmulator *emulator;

@end

@implementation NESGameViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSURL *applicationSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject];
        NSURL *configURL = [applicationSupportURL URLByAppendingPathComponent:@"nesemu2.cfg"];
        [[NSFileManager defaultManager] createDirectoryAtURL:applicationSupportURL withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createFileAtPath:configURL.path contents:nil attributes:nil];
        
        _emulator = [[NESEmulator alloc] initWithConfigurationURL:configURL dataDirectoryURL:applicationSupportURL];
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
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.emulator.layer.frame = self.view.bounds;
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
