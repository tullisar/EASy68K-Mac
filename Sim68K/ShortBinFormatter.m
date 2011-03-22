//
//  ShortBinFormatter.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShortBinFormatter.h"

#include "extern.h"

@implementation ShortBinFormatter

// -----------------------------------------------------------------
// stringForObjectValue
// Gets the final string that'll be used to represent the formatted
// number
// -----------------------------------------------------------------
- (NSString *)stringForObjectValue:(id)obj 
{ 
    NSString *result = @"0000000000000000";
    
    if([obj isKindOfClass:[NSNumber class]]) {
        result = binaryStringForValue([obj unsignedShortValue]);
    } else if ([obj isKindOfClass:[NSString class]]) {
        NSNumber *value = binaryStringToValue(obj);
        result = binaryStringForValue([value unsignedShortValue]);
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
    BOOL success = YES;
    NSNumber *binValue = binaryStringToValue(string);
    *obj = binValue;
    return success; 
} 

// -----------------------------------------------------------------
// isPartialStringValid
// Checks that characters are valid as they are typed in
// -----------------------------------------------------------------
- (BOOL)isPartialStringValid:(NSString *)partialString 
            newEditingString:(NSString **)newString 
            errorDescription:(NSString **)error 
{
    BOOL result = NO;
    
    NSMutableString *tempString = [NSMutableString stringWithString:partialString];
    NSCharacterSet *illegalCharacters = CHARSET_BIN;
    NSRange illegalCharacterRange = [tempString rangeOfCharacterFromSet:illegalCharacters];
    
    while (illegalCharacterRange.location != NSNotFound)
    {
        [tempString deleteCharactersInRange:illegalCharacterRange];
        illegalCharacterRange = [tempString rangeOfCharacterFromSet:illegalCharacters];
    }
    
    *newString = tempString;
    
    return result;
}

// -----------------------------------------------------------------
// isPartialStringValid
// Checks that characters are valid as they are typed in
// -----------------------------------------------------------------
- (BOOL)isPartialStringValid:(NSString **)partialStringPtr 
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr 
              originalString:(NSString *)origString 
       originalSelectedRange:(NSRange)origSelRange 
            errorDescription:(NSString **)error
{
    NSMutableString *tempString = [NSMutableString stringWithString:*partialStringPtr];
    
    NSCharacterSet *illegalCharacters = CHARSET_BIN;
    NSRange illegalCharacterRange = [tempString rangeOfCharacterFromSet:illegalCharacters];
    if (illegalCharacterRange.location != NSNotFound)                                       // Illegal chars
        return NO;
    
    if ([*partialStringPtr length] == 0) {                                                  // Empty string
        *partialStringPtr = @"0000000000000000";
        return NO;
    }
    
    if ([*partialStringPtr length] > 16) {                                                  // Length limit
        return NO;
    }
    
    return YES;
}

@end
