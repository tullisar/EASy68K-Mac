//
//  NSNumber-StrUtils.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSNumber-StrUtils.h"

@implementation NSNumber (StrUtils)

- (NSString *)hexString {
    NSString *hex = [NSString stringWithFormat:@"%x",[self intValue]];
    return hex;
}

@end
