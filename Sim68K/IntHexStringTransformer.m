//
//  IntHexStringTransformer.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IntHexStringTransformer.h"

@implementation IntHexStringTransformer

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
// Returns the string representation of a 4-byte hex value
// -----------------------------------------------------------------
- (id)transformedValue:(id)value {
    return [NSString stringWithFormat:@"%08X",[value unsignedIntValue]];
}

// -----------------------------------------------------------------
// reverseTransformedValue
// Reverses the transformation to a 4-byte hex string
// -----------------------------------------------------------------
- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        NSScanner *temp = [NSScanner scannerWithString:(NSString *)value];
        unsigned int result = 0;
        if ([temp scanHexInt:&result])
            return [NSNumber numberWithInt:result];
    } else {
        if ([value respondsToSelector:@selector(intValue)])
            return [NSNumber numberWithInt:[value intValue]];
    }
    return 0;
}

@end
