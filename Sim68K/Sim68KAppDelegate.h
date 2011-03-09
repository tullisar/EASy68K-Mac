//
//  Sim68KAppDelegate.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NoodleLineNumberView, Simulator;

@interface Sim68KAppDelegate : NSObject {
// @interface Sim68KAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSPanel  *panelIO;
    NSPanel  *panelHardware;
    NSPanel  *panelStack;
    NSPanel  *panelMemory;
    IBOutlet NSScrollView   *scrollView;
    IBOutlet NSTextView     *scriptView;
	NoodleLineNumberView	*lineNumberView;
    
    IBOutlet Simulator      *simulator;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPanel  *panelIO;
@property (assign) IBOutlet NSPanel *panelHardware;
@property (assign) IBOutlet NSPanel *panelStack;
@property (assign) IBOutlet NSPanel *panelMemory;

@end
