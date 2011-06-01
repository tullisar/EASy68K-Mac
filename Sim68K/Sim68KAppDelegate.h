/***************************** 68000 SIMULATOR ****************************
 
 File Name: Sim68KAppDelegate.m
 Version: 1.0 (Mac OS X)
 
 Definition file for the application delegate (controller in MVC)

 Created:  2011-04-15
           Robert Bartlett-Schneider
 
 ***************************************************************************/

#import <Cocoa/Cocoa.h>
#import "ConsoleView.h"
#import "SynchronizedScrollView.h"
#import "SynchronizedScrollController.h"
#import "ListfileDebugView.h"

@class NoodleLineNumberView, Simulator;

@interface Sim68KAppDelegate : NSObject {
    NSWindow                *window;
    NSPanel                 *panelIO;
    NSPanel                 *panelHardware;
    NSPanel                 *panelStack;
    NSPanel                 *panelMemory;
    NSPanel                 *panelBreaks;
    ConsoleView             *simIOView;
    IBOutlet NSScrollView   *scrollView;
    IBOutlet ListfileDebugView *scriptView;
	NoodleLineNumberView	*lineNumberView;
    IBOutlet NSTextView     *errorOutput;
    
    IBOutlet NSTextView     *memAddressColumn;
    IBOutlet NSTextView     *memValueColumn;
    IBOutlet NSTextView     *memContentsColumn;
    IBOutlet NSTextView     *stackAddressColumn;
    IBOutlet NSTextView     *stackValueColumn;
    IBOutlet NSPopUpButton  *stackSelectMenu;
    
    IBOutlet SynchronizedScrollView   *memAddressScroll;
    IBOutlet SynchronizedScrollView   *memValueScroll;
    IBOutlet SynchronizedScrollView   *memContentsScroll;
    IBOutlet SynchronizedScrollView   *stackAddressScroll;
    IBOutlet SynchronizedScrollView   *stackValueScroll;
    
    SynchronizedScrollController *mBrowser;
    SynchronizedScrollController *sBrowser;

    NSString                *file;
    IBOutlet Simulator      *simulator;
    
    int                     memDisplayLength;
    unsigned int            memDisplayStart;
    unsigned int            stackDisplayLoc;
    
    BOOL                    appLaunched;
    BOOL                    delayedOpen;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPanel *panelIO;
@property (assign) IBOutlet NSPanel *panelHardware;
@property (assign) IBOutlet NSPanel *panelStack;
@property (assign) IBOutlet NSPanel *panelMemory;
@property (assign) IBOutlet NSPanel *panelBreaks;
@property (retain) NSString *file;
@property (assign) IBOutlet ConsoleView *simIOView;
@property (retain) Simulator *simulator;
@property (assign) unsigned int memDisplayStart;
@property (assign) unsigned int stackDisplayLoc;
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
- (IBAction)stackPageChange:(id)sender;
- (IBAction)stackSelect:(id)sender;
- (void)highlightCurrentInstruction;
- (BOOL)isInstruction:(NSString *)theLine;
- (void)initListfileView;
- (void)initMemoryScrollers;
- (void)initStackScrollers;
- (void)updateStackDisplay;
- (void)updateMemDisplay;
- (unsigned int)memDisplayStart;
- (void)setMemDisplayStart:(unsigned int)newStart;

@end
