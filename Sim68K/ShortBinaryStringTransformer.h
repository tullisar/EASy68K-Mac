//
//  ShortBinaryStringTransformer.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#define WORD68K 16

@interface ShortBinaryStringTransformer : NSValueTransformer {}

- (NSMutableString *)binaryStringForValue:(unsigned short)value;

@end
