//
//  main.m
//  NES
//
//  Created by Conrad Kramer on 4/23/15.
//  Copyright (c) 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <nesemu2/nesemu2.h>

#import "NESGameViewController.h"

@interface PUICApplication : UIApplication <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@end

@interface NESApplication : PUICApplication

@end

@implementation NESApplication

- (BOOL)application:(NESApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL success = [super application:application didFinishLaunchingWithOptions:launchOptions];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[NESGameViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    return success;
}

@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, NSStringFromClass([NESApplication class]), NSStringFromClass([NESApplication class]));
    }
}
