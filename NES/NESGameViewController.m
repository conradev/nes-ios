//
//  ViewController.m
//  NES
//
//  Created by Conrad Kramer on 4/23/15.
//  Copyright (c) 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <nesemu2/nesemu2.h>

#import "NESGameViewController.h"
#import "NESGameView.h"

@interface NESGameViewController ()

@property(nonatomic, strong) NESGameView *view;

@end

@implementation NESGameViewController

@dynamic view;

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
    self.view = [[NESGameView alloc] initWithEmulator:self.emulator];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.emulator loadRomAtURL:[[NSBundle mainBundle] URLForResource:@"smb" withExtension:@"nes"]];
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
