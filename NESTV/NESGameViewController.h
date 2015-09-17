//
//  NESGameViewController.h
//  NESTV
//
//  Created by Conrad Kramer on 9/16/15.
//  Copyright © 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NESEmulator;

@interface NESGameViewController : UIViewController

@property (nonatomic, readonly) NESEmulator *emulator;

@end

