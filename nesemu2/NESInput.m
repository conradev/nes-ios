//
//  NESInput.m
//  NES
//
//  Created by Conrad Kramer on 6/13/15.
//  Copyright © 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import "NESEmulator.h"

#include "types.h"

extern NESEmulator *emulator;

int joyx,joyy;
u8 joyzap;
u8 joykeys[32];
int joyconfig[4][8];

int input_init() {
    for (int player = 0; player < 4; player++) {
        for (int button = 0; button < 8; button++) {
            joyconfig[player][button] = player * (sizeof(NESControllerState) * CHAR_BIT) + button;
        }
    }
    
    return 0;
}

void input_kill() {

}

void input_poll() {
    NESControllerState controllers[] = {emulator.player1, emulator.player2, emulator.player3, emulator.player4};
    for (int player = 0; player < 4; player++) {
        int offset = (sizeof(NESControllerState) * CHAR_BIT * player);
        NESControllerState controller = controllers[player];
        joykeys[offset + 0] = (controller & NESControllerStateA);
        joykeys[offset + 1] = (controller & NESControllerStateB);
        joykeys[offset + 2] = (controller & NESControllerStateSelect);
        joykeys[offset + 3] = (controller & NESControllerStateStart);
        joykeys[offset + 4] = (controller & NESControllerStateUp);
        joykeys[offset + 5] = (controller & NESControllerStateDown);
        joykeys[offset + 6] = (controller & NESControllerStateLeft);
        joykeys[offset + 7] = (controller & NESControllerStateRight);
    }    
}

int input_poll_mouse(int *x, int *y) {
    return 0;
}

void input_update_config() {
    
}
