//
//  ConsoleView.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConsoleView.h"


@implementation ConsoleView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}

- (void)keyDown:(NSEvent *)theEvent {
    pendingKey = [[theEvent characters] cStringUsingEncoding:NSUTF8StringEncoding];
    [super keyDown:theEvent];
}

@end
