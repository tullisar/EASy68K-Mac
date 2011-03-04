//
//  Simulator.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Simulator : NSObject {

    // Registers
    unsigned long  A0,A1,A2,A3,A4,A5,A6,A7;
    unsigned long  D0,D1,D2,D3,D4,D5,D6,D7;
    unsigned short GUI_SR;
    unsigned long  GUI_US, GUI_SS, GUI_PC;    
    
}

@property (assign) unsigned long A0;
@property (assign) unsigned long A1;
@property (assign) unsigned long A2;
@property (assign) unsigned long A3;
@property (assign) unsigned long A4;
@property (assign) unsigned long A5;
@property (assign) unsigned long A6;
@property (assign) unsigned long A7;
@property (assign) unsigned long D0;
@property (assign) unsigned long D1;
@property (assign) unsigned long D2;
@property (assign) unsigned long D3;
@property (assign) unsigned long D4;
@property (assign) unsigned long D5;
@property (assign) unsigned long D6;
@property (assign) unsigned long D7;
@property (assign) unsigned short GUI_SR;
@property (assign) unsigned long GUI_US;
@property (assign) unsigned long GUI_SS;
@property (assign) unsigned long GUI_PC;

- (void) initSim;
- (void) memFormat;
- (void) runLoop;
- (void) loadProgram;

@end
