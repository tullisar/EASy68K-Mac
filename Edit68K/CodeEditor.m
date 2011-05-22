//
//  CodeEditor.m
//  Edit68K
//
//  Created by Robert Bartlett-Schneider on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CodeEditor.h"

@implementation CodeEditor

// -----------------------------------------------------------------
// init
// Default initialization for the textView
// -----------------------------------------------------------------
-(id)init {
    self = [super init];
    if (self) {

        // NSMutableParagraphStyle *tabControl = [[NSMutableParagraphStyle alloc] init];
        NSParagraphStyle *tabControl = [NSParagraphStyle defaultParagraphStyle];
        // [self setDefaultParagraphStyle:];
        
    }
    return self;
}

// -----------------------------------------------------------------
// awakeFromNib
// Called when loaded from the nib file
// -----------------------------------------------------------------
-(void)awakeFromNib {
    
    NSParagraphStyle *def = [NSParagraphStyle defaultParagraphStyle];
}

@end
