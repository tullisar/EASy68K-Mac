//
//  SimErrorManager.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SimErrorManager.h"
#import "NSTextView-TextManipulation.h"

#include "extern.h"

@implementation SimErrorManager

// -----------------------------------------------------------------
// log
// Logs output to the application error view
// -----------------------------------------------------------------
+ (void)log:(NSString *)string {
    NSString *newString = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    newString = [newString stringByAppendingString:@"\n"];
    [[appDelegate errorOutput] appendString:newString
                                   withFont:CONSOLE_FONT];
}

@end
