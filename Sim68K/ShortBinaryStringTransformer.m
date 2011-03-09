//
//  ShortBinaryStringTransformer.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShortBinaryStringTransformer.h"

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
    return NO;
}

// -----------------------------------------------------------------
// transformedValue
// -----------------------------------------------------------------
- (id)transformedValue:(id)value {
    return [self binaryStringForValue:(unsigned short)[value shortValue]];
}

// -----------------------------------------------------------------
// binaryStringForValue
// -----------------------------------------------------------------
- (NSMutableString *)binaryStringForValue:(unsigned short)value {
    int position = WORD68K;
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    do {                                            // Check if bit is set
        if (value & 1) {
            [buffer insertString:@"1" atIndex:0];   // Yes
            position--;
        } else {
            [buffer insertString:@"0" atIndex:0];   // No
            position--;
        }
        value >>= 1;
    } while (value > 0);
    
    while (position > 0) {                          // Fill remaining length with zeros
        [buffer insertString:@"0" atIndex:0];
        position--;
    }
    
    return [buffer autorelease];
    
}

@end
