//
//  BreakpointDelegate.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BreakpointDelegate : NSObject {
    
}

+ (int)sbpoint:(int)loc;
+ (int)cbpoint:(int)loc;

@end
