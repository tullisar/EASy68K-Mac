//
//  ShortBinFormatter.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShortBinFormatter.h"

NSString* binaryStringForValue(unsigned short value);

@implementation ShortBinFormatter

// -----------------------------------------------------------------
// stringForObjectValue
// Gets the final string that'll be used to represent the formatted
// number
// -----------------------------------------------------------------
- (NSString *)stringForObjectValue:(id)obj { 
    NSString *result = @"0000000000000000";
    
    if([obj isKindOfClass:[NSNumber class]]) {
        result = binaryStringForValue([obj unsignedShortValue]);
    } else if ([obj isKindOfClass:[NSString class]]) {
        NSScanner *temp = [NSScanner scannerWithString:obj];
        unsigned int value = 0;
        if ([temp scanHexInt:&value]) {
            result = [NSString stringWithFormat:@"%08X",value];
        }
        if (value == 0x1000000) {
            int a = 0; // testbreak
        }
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
    if ([temp scanHexInt:&result]) {
        hexValue = [NSNumber numberWithUnsignedInt:result];
        success = YES;
    } else {
        hexValue = [NSNumber numberWithUnsignedInt:0];
    }    
    
    *obj = hexValue;
    
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
    NSCharacterSet *illegalCharacters = 
    [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef"] invertedSet];
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
    
    BOOL result = NO;
    
    return result;
    
}

@end
