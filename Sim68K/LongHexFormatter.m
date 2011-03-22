//
//  LongHexFormatter.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LongHexFormatter.h"
#include "extern.h"

@implementation LongHexFormatter

// -----------------------------------------------------------------
// stringForObjectValue
// Gets the final string that'll be used to represent the formatted
// number
// -----------------------------------------------------------------
- (NSString *)stringForObjectValue:(id)obj { 
    NSString *result = @"00000000";                                         // Default value if invalid
    
    if([obj isKindOfClass:[NSNumber class]]) {                              // Formatting number already
        result = [NSString stringWithFormat:@"%08X", (int)[obj intValue]];  // Print hex to string
    } else if ([obj isKindOfClass:[NSString class]]) {                      // Formatting a string
        NSScanner *temp = [NSScanner scannerWithString:obj];                
        unsigned int value = 0;
        if ([temp scanHexInt:&value])                                       // Scan for hex value in string
            result = [NSString stringWithFormat:@"%08X",value];
    }    
    return result; 
} 

// -----------------------------------------------------------------
// getObjectValue
// Gets an NSNumber represented by the string supplied.
// -----------------------------------------------------------------
- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string 
      errorDescription:(NSString **)error  
{ 
    NSNumber *hexValue;
    BOOL success = NO;
    
    NSScanner *temp = [NSScanner scannerWithString:(NSString *)string];
    unsigned int result = 0;
    
    if ([temp scanHexInt:&result]) {                                        // Scan for hex value in string
        hexValue = [NSNumber numberWithInt:result];
        success = YES;
    } else {
        hexValue = [NSNumber numberWithInt:0];                              // Default to 0 if scan failure
    }    
    
    *obj = hexValue;
    
    return success; 
} 

// -----------------------------------------------------------------
// isPartialStringValid
// Checks that characters are valid as they are typed in
// -----------------------------------------------------------------
//- (BOOL)isPartialStringValid:(NSString *)partialString 
//            newEditingString:(NSString **)newString 
//            errorDescription:(NSString **)error 
//{
//    // Result always NO until enter is pressed to confirm
//    BOOL result = NO;
//    
//    NSMutableString *tempString = [NSMutableString stringWithString:partialString];
//    NSCharacterSet *illegalCharacters = CHARSET_HEX;
//    NSRange illegalCharacterRange = [tempString rangeOfCharacterFromSet:illegalCharacters];
//    
//    while (illegalCharacterRange.location != NSNotFound)                                    // Remove non hex chars
//    {
//        [tempString deleteCharactersInRange:illegalCharacterRange];
//        illegalCharacterRange = [tempString rangeOfCharacterFromSet:illegalCharacters];
//    }
//    
//    *newString = tempString;                                                                // Pass clean string
//    
//    return result;
//}

// -----------------------------------------------------------------
// isPartialStringValid
// Checks that characters are valid as they are typed in
// -----------------------------------------------------------------
- (BOOL)isPartialStringValid:(NSString **)partialStringPtr 
       proposedSelectedRange:(NSRange *)proposedSelRangePtr 
              originalString:(NSString *)origString 
       originalSelectedRange:(NSRange)origSelRange 
            errorDescription:(NSString **)error
{
    NSMutableString *tempString = [NSMutableString stringWithString:*partialStringPtr];

    NSCharacterSet *illegalCharacters = CHARSET_HEX;
    NSRange illegalCharacterRange = [tempString rangeOfCharacterFromSet:illegalCharacters];
    if (illegalCharacterRange.location != NSNotFound)                                       // Illegal chars
        return NO;
    
    if ([*partialStringPtr length] == 0) {                                                  // Empty string
        *partialStringPtr = @"00000000";
        return NO;
    }

    if ([*partialStringPtr length] > 8) {                                                   // Length limit
        return NO;
    }
    
    return YES;
}

@end
