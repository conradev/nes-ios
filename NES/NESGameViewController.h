//
//  ViewController.h
//  NES
//
//  Created by Conrad Kramer on 4/23/15.
//  Copyright (c) 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NESEmulator;

@interface NESGameViewController : UIViewController

@property (nonatomic, readonly) NESEmulator *emulator;

@end
