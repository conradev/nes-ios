//
//  NESSystem.m
//  NES
//
//  Created by Conrad Kramer on 6/13/15.
//  Copyright © 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <mach/mach_time.h>

#include "emu.h"

int system_init() {
    return 0;
}

void system_kill() {

}

void system_checkevents() {

}

char *system_getcwd() {
    return (char *)[NSHomeDirectory() fileSystemRepresentation];
}

u64 system_gettick() {
    static struct mach_timebase_info info;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mach_timebase_info(&info);
    });
    
    return ((mach_absolute_time() * info.numer / info.denom) / 1000000);
}

u64 system_getfrequency() {
    return 1000;
}

int system_findconfig(char *dest) {
    return 0;
}
