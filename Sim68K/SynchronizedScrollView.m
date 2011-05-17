//
//  SynchronizedScrollView
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SynchronizedScrollView.h"

@implementation SynchronizedScrollView

@synthesize lastScrollPoint;
@synthesize acceptsScrollWheel;
@synthesize name;

// -----------------------------------------------------------------
// scrollWheel
// Intercepts the scroll wheel event to block secondary views from
// scrolling.
// -----------------------------------------------------------------
-(void)scrollWheel:(NSEvent *)theEvent {
    if (acceptsScrollWheel) {
        [super scrollWheel:theEvent];
    }
}

@end
