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
    
    // TODO: Allow pasting of a word (0x2700 for example) and have it automatically convert to binary
    
    NSCharacterSet *illegalCharacters = CHARSET_BIN;
    NSRange illegalCharacterRange = [tempString rangeOfCharacterFromSet:illegalCharacters];
    if (illegalCharacterRange.location != NSNotFound)                                       // Illegal chars
        return NO;
    
    int lengthDif = [origString length] - [*partialStringPtr length];
    
    if (lengthDif == [origString length]) {                                                 // Empty String
        *partialStringPtr = @"0000000000000000";    
    } 
    
    else if (lengthDif < 0) {                                                               // Longer String
        if (origSelRange.location == [origString length])
            return NO;
        
        if (lengthDif == -1) {                                                              // Single character
            NSRange delRange = NSMakeRange(origSelRange.location+1, 1);
            [tempString deleteCharactersInRange:delRange];
            *partialStringPtr = tempString;
            if (delRange.location == [origString length]) delRange.location--;
            *proposedSelRangePtr = delRange;
        }
        
        if (lengthDif == -16) {                                                             // Pasting full string
            if (origSelRange.location == 0) {                                               // Only accept at index 0
                *partialStringPtr = [tempString substringToIndex:8];
                proposedSelRangePtr->location = 0;
                proposedSelRangePtr->length = 16;
            }
        }
    }
    
    else if (lengthDif > 0) {                                                               // Shorter String
        int selDif = [origString length]-origSelRange.length+1;
        if (selDif == [*partialStringPtr length]) {
            NSRange replaceRange = NSMakeRange(0, proposedSelRangePtr->location);
            tempString = [NSMutableString stringWithString:origString];
            NSString *newStart = [*partialStringPtr substringToIndex:proposedSelRangePtr->location];
            [tempString replaceCharactersInRange:replaceRange withString:newStart];
            *partialStringPtr = tempString;
            proposedSelRangePtr->length++;
        }
    }
    
    if (lengthDif == 0) {                                                                   // Same length
        proposedSelRangePtr->length++;
        *partialStringPtr = tempString;
    }
    
    return NO;
}

@end
