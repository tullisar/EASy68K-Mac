//
//  ShortHexStringTransformer.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UShortHexStringTransformer.h"

@implementation UShortHexStringTransformer

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
// Returns the string representation of a given number as a hex
// of 2 bytes in length.
// -----------------------------------------------------------------
- (id)transformedValue:(id)value {
    return [NSString stringWithFormat:@"%04X",[value unsignedShortValue]];
}

// -----------------------------------------------------------------
// reverseTransformedValue
// Reverses the transformation from a 2-byte hex string to a number
// -----------------------------------------------------------------
- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        NSScanner *temp = [NSScanner scannerWithString:(NSString *)value];
        unsigned int result = 0;
        if ([temp scanHexInt:&result]) {
            return [NSNumber numberWithUnsignedInt:result];
        } else {
            return 0;
        }
    } else {
        if ([value respondsToSelector:@selector(unsignedShortValue)]) {
            return [NSNumber numberWithUnsignedInt:[value unsignedShortValue]];
        }
    }
    return 0;
}

@end
