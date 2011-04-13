//
//  Simulator.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define CLOCKSPEED 0.0000125

@interface Simulator : NSObject {

    // Registers
    long  A0,A1,A2,A3,A4,A5,A6,A7;
    long  D0,D1,D2,D3,D4,D5,D6,D7;
    short GUI_SR;
    long  GUI_US, GUI_SS, GUI_PC; 
    
    // Misc Properties
    unsigned long int GUI_Cycles;
    long  startPC;
    BOOL  simLoaded;
    BOOL  simStopped;
    BOOL  simInputMode;
    
    // Containers
    NSAttributedString *listFile;
    NSArray            *listFileLines;
}

@property (assign) long A0;
@property (assign) long A1;
@property (assign) long A2;
@property (assign) long A3;
@property (assign) long A4;
@property (assign) long A5;
@property (assign) long A6;
@property (assign) long A7;
@property (assign) long D0;
@property (assign) long D1;
@property (assign) long D2;
@property (assign) long D3;
@property (assign) long D4;
@property (assign) long D5;
@property (assign) long D6;
@property (assign) long D7;
@property (assign) short GUI_SR;
@property (assign) long GUI_US;
@property (assign) long GUI_SS;
@property (assign) long GUI_PC;
@property (assign) unsigned long int GUI_Cycles;
@property (retain) NSAttributedString *listFile;
@property (retain) NSArray            *listFileLines;
@property (assign) long startPC;
@property (assign) BOOL simLoaded;
@property (assign) BOOL simStopped;
@property (assign) BOOL simInputMode;

- (void) initSim;
- (void) memFormat;
- (void) runLoop;
- (void) loadProgram:(NSString*)name;
- (void) displayReg;
- (void) runProg;
- (void) step;
- (void) trace;
- (void) pause;
- (void) rewind;
- (void) runToCursor:(long)location;
- (BOOL) isInstruction:(NSString *)line;
- (NSTextStorage *)memoryContents;
- (void)setMemoryContents:(NSTextStorage *)contents;
- (NSTextStorage *)memoryAddresses;
- (void)setMemoryAddresses:(NSTextStorage *)addresses;
- (NSTextStorage *)memoryASCII;
- (void)setMemoryASCII:(NSTextStorage *)ascii;

@end
