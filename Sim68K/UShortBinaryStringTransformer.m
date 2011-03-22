//
//  ShortBinaryStringTransformer.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UShortBinaryStringTransformer.h"

#include "extern.h"

@implementation UShortBinaryStringTransformer

// -----------------------------------------------------------------
// transformedValueClass
// returns the class of the transformed value
// -----------------------------------------------------------------
+ (Class)transformedValueClass {
    return [NSString class];
}

// -----------------------------------------------------------------
// allowReverseTransformation
// Determines whether the transformer allows reverse transformation
// -----------------------------------------------------------------
+ (BOOL)allowsReverseTransformation {
    return YES;
}

// -----------------------------------------------------------------
// transformedValue
// Returns the string representation of an unsigned 16 bit binary number
// -----------------------------------------------------------------
- (id)transformedValue:(id)value {
    return binaryStringForValue([value unsignedShortValue]);
}

// -----------------------------------------------------------------
// reverseTransformedValue
// Reverses the transform from a number to a string.
// -----------------------------------------------------------------
- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]])
        return binaryStringToValue(value);
    else
        if ([value respondsToSelector:@selector(unsignedShortValue)])
            return [NSNumber numberWithUnsignedShort:[value unsignedShortValue]];
    return 0;
}

@end
