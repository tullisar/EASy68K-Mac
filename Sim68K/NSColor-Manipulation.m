//
//  NSColor-Manipulation.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSColor-Manipulation.h"


@implementation NSColor (Manipulation)

- (NSColor *)inverted {
 
    NSColor *original = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    return [NSColor colorWithCalibratedRed:(1.0 - [original redComponent])
                                     green:(1.0 - [original greenComponent])
                                      blue:(1.0 - [original blueComponent])
                                     alpha:[original alphaComponent]];
    
}

@end
