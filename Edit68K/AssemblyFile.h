//
//  AssemblyFile.h
//  Edit68K
//
//  Created by Robert Bartlett-Schneider on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CodeEditor.h"
#include "asm.h"

#define CONSOLE_FONT       [NSFont fontWithName:@"Courier" size:11]
#define CONSOLE_FONT_COLOR [NSColor whiteColor]

extern bool listFlag;
extern bool objFlag;
extern bool CEXflag;
extern bool BITflag;
extern bool CREflag;
extern bool MEXflag;
extern bool SEXflag;
extern bool WARflag;
extern int errorCount;
extern int warningCount;

extern int assembleFile(char fileName[], char tempName[], char workName[]);

@class NoodleLineNumberView;

@interface AssemblyFile : NSDocument {
    
    IBOutlet CodeEditor *textView;
    IBOutlet NSScrollView *scrollView;
    NoodleLineNumberView *lineNumberView;
    
    NSTextStorage *textStorage;
    
    BOOL savedYet;
    BOOL noErrors;
    NSString *errorDisplay;
    
}

@property (readwrite, retain) NSTextStorage *textStorage;
@property (retain) NSString *errorDisplay;
@property (assign) BOOL noErrors;

- (NSTextStorage *)textStorage;
- (void)setTextStorage:(NSTextStorage *) value;
- (void)initTextStorage;
- (void)initCodeEditor;
- (void)codeTextDidChange:(NSNotification *)notify;
- (CGFloat)tabWidthForTextAttributes:(NSDictionary *)attr;
- (IBAction)assemble:(id)sender;

@end
