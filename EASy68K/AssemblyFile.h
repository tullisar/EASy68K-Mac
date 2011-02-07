//
//  MyDocument.h
//  EASy68K
//
//  Created by Robert Bartlett-Schneider on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "asm.h"

extern bool listFlag;
extern bool objFlag;


@interface AssemblyFile : NSDocument {
    
    IBOutlet NSTextView *textView;
    NSTextStorage *textStorage;
    
}

@property (readwrite, retain) NSTextStorage *textStorage;

- (NSTextStorage *) textStorage;
- (void) setTextStorage:(NSTextStorage *) value;
- (void) initTextStorage;

@end
