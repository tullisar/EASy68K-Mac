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
// -----------------------------------------------------------------
- (id)transformedValue:(id)value {
    int result = [value intValue];
    return [NSString stringWithFormat:@"%08X",result];
}

// -----------------------------------------------------------------
// reverseTransformedValue
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
        if ([value respondsToSelector:@selector(intValue)]) {
            int test = [value intValue];
            return [NSNumber numberWithUnsignedInt:test];
        }
    }
    return 0;
}

@end
