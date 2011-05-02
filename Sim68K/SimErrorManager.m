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

+ (void)log:(NSString *)string {
    [[appDelegate errorOutput] appendString:string
                                   withFont:CONSOLE_FONT];
}

@end
