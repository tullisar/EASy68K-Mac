//
//  SynchronizedScrollView.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SynchronizedScrollView : NSScrollView {
    
    NSPoint lastScrollPoint;
    BOOL    acceptsScrollWheel;
    NSString *name;
    
}

@property (assign) NSPoint lastScrollPoint;
@property (assign) BOOL    acceptsScrollWheel;
@property (retain) NSString *name;

@end
