//
//  NESTodayViewController.m
//  NESWidget
//
//  Created by Conrad Kramer on 6/6/15.
//  Copyright (c) 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <nesemu2/NESEmulator.h>

#import "NESTodayViewController.h"

@implementation NESTodayViewController

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
    
    self.preferredContentSize = CGSizeMake(0, 300);
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

- (void)viewWillLayoutSubviews {
    self.emulator.layer.frame = self.view.bounds;
    [super viewWillLayoutSubviews];
}

#pragma mark - NCWidgetProviding

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}

@end
