//
//  ShortBinaryStringTransformer.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShortBinaryStringTransformer.h"

NSString* binaryStringForValue(unsigned short value);

@implementation ShortBinaryStringTransformer

// -----------------------------------------------------------------
// transformedValueClass
// returns the class of the transformed value
// -----------------------------------------------------------------
+ (Class)transformedValueClass {
    return [NSMutableString class];
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
    return binaryStringForValue([value unsignedShortValue]);
}

// -----------------------------------------------------------------
// reverseTransformedValue
// -----------------------------------------------------------------
- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        char buf[17];
        sprintf(buf, "%s", [value cStringUsingEncoding:NSUTF8StringEncoding]);
        int value = 0;
        for (int i = 0; i < strlen(buf)-1; i++) {
            if (buf[i] == '1') (value |= 1);
            value <<= 1;
        }
        return [NSNumber numberWithUnsignedInt:value];
    } else {
        if ([value respondsToSelector:@selector(intValue)]) {
            int test = [value intValue];
            return [NSNumber numberWithUnsignedInt:test];
        }
    }
    return 0;
}
@end
