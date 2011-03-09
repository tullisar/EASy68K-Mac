//
//  ShortHexStringTransformer.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShortHexStringTransformer.h"

@implementation ShortHexStringTransformer

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
    return NO;
}

// -----------------------------------------------------------------
// transformedValue
// -----------------------------------------------------------------
- (id)transformedValue:(id)value {
    return [NSString stringWithFormat:@"%04X",[value shortValue]];
}

@end
