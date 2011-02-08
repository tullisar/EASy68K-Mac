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

extern int assembleFile(char fileName[], char tempName[], char workName[]);

@interface AssemblyFile : NSDocument {
    
    IBOutlet NSTextView *textView;
    NSTextStorage *textStorage;
    
}

@property (readwrite, retain) NSTextStorage *textStorage;

- (NSTextStorage *) textStorage;
- (void) setTextStorage:(NSTextStorage *) value;
- (void) initTextStorage;
- (IBAction)assemble:(id)sender;

@end
