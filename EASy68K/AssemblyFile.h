//
//  AssemblyFile.h
//  Edit68K
//
//  Created by Robert Bartlett-Schneider on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "asm.h"

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

@interface AssemblyFile : NSDocument {
    
    IBOutlet NSTextView *textView;
    NSTextStorage *textStorage;
    
    BOOL savedYet;
    BOOL noErrors;
    NSString *errorDisplay;
    
}

@property (readwrite, retain) NSTextStorage *textStorage;
@property (retain) NSString *errorDisplay;
@property (assign) BOOL noErrors;

- (NSTextStorage *) textStorage;
- (void) setTextStorage:(NSTextStorage *) value;
- (void) initTextStorage;
- (IBAction)assemble:(id)sender;

@end
