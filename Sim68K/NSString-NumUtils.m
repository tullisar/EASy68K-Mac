//
//  NSString-HexUtils.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString-NumUtils.h"

@implementation NSString (NumUtils)

// -----------------------------------------------------------------
// unsignedHexValue
// returns (as an NSNumber) the number represented by the string
// containing a formatted hex string.
// TODO: Implement an error return mechanism
// -----------------------------------------------------------------
- (NSNumber *)unsignedHexValue {

    NSNumber *hexValue;
    BOOL success = NO;
    
    NSScanner *temp = [NSScanner scannerWithString:(NSString *)self];
    unsigned int result = 0;
    
    if ([temp scanHexInt:&result]) {                            // Scan for hex value in string
        hexValue = [NSNumber numberWithUnsignedInt:result];
        success = YES;
    } else {
        hexValue = [NSNumber numberWithUnsignedInt:0];          // Default to 0 if scan failure
    }    
    
    return hexValue;
    
}

@end
