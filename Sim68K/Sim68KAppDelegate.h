//
//  Sim68KAppDelegate.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "ConsoleView.h"
#import "SynchronizedScrollView.h"
#import "MemBrowserScrollSynchronizer.h"
#import "ListfileDebugView.h"

@class NoodleLineNumberView, Simulator;

@interface Sim68KAppDelegate : NSObject {
    NSWindow                *window;
    NSPanel                 *panelIO;
    NSPanel                 *panelHardware;
    NSPanel                 *panelStack;
    NSPanel                 *panelMemory;
    ConsoleView             *simIOView;
    IBOutlet NSScrollView   *scrollView;
    IBOutlet ListfileDebugView *scriptView;
	NoodleLineNumberView	*lineNumberView;
    IBOutlet NSTextView     *errorOutput;
    
    IBOutlet NSTextView     *memAddressColumn;
    IBOutlet NSTextView     *memValueColumn;
    IBOutlet NSTextView     *memContentsColumn;
    
    IBOutlet SynchronizedScrollView   *memAddressScroll;
    IBOutlet SynchronizedScrollView   *memValueScroll;
    IBOutlet SynchronizedScrollView   *memContentsScroll;
    
    MemBrowserScrollSynchronizer *mBrowser;

    NSString                *file;
    IBOutlet Simulator      *simulator;
    
    int                     memDisplayLength;
    unsigned int            memDisplayStart;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPanel  *panelIO;
@property (assign) IBOutlet NSPanel *panelHardware;
@property (assign) IBOutlet NSPanel *panelStack;
@property (assign) IBOutlet NSPanel *panelMemory;
@property (retain) NSString *file;
@property (assign) IBOutlet ConsoleView *simIOView;
@property (retain) Simulator *simulator;
@property (assign) unsigned int memDisplayStart;
@property (assign) IBOutlet NSTextView *errorOutput;

- (IBAction)openDocument:(id)sender;
- (IBAction)runProg:(id)sender;
- (IBAction)step:(id)sender;
- (IBAction)trace:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)rewindProg:(id)sender;
- (IBAction)runToCursor:(id)sender;
- (IBAction)reload:(id)sender;
- (IBAction)changeMemLength:(id)sender;
- (IBAction)memPageChange:(id)sender;
- (void)highlightCurrentInstruction;
- (BOOL)isInstruction:(NSString *)theLine;
- (void)initListfileView;
- (void)initMemoryScrollers;
- (void)updateMemDisplay;
- (unsigned int)memDisplayStart;
- (void)setMemDisplayStart:(unsigned int)newStart;

@end
