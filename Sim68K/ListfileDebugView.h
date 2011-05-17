//
//  ListfileDebugView.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ListfileDebugView : NSTextView {

    long selectedPC;
    
}

@property (assign) long selectedPC;

- (void)highlightCurrentInstruction;

@end
