//
//  NESAppDelegate.m
//  NES
//
//  Created by Conrad Kramer on 4/23/15.
//  Copyright (c) 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import "NESAppDelegate.h"
#import "NESGameViewController.h"

@implementation NESAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[NESGameViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
