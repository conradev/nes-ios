//
//  NESTodayViewController.h
//  NESWidget
//
//  Created by Conrad Kramer on 6/6/15.
//  Copyright (c) 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NotificationCenter/NotificationCenter.h>

@class NESEmulator;

@interface NESTodayViewController : UIViewController <NCWidgetProviding>

@property (nonatomic, readonly) NESEmulator *emulator;

@end
