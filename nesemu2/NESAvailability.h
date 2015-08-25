//
//  NESAvailability.h
//  NES
//
//  Created by Conrad Kramer on 6/17/15.
//  Copyright © 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <TargetConditionals.h>

#define METAL_ENABLED !TARGET_IPHONE_SIMULATOR && !TARGET_OS_WATCH
#define OPENGL_ENABLED !TARGET_OS_WATCH
