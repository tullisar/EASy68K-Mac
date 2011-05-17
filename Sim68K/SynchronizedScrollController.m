//
//  MemBrowserScrollSynchronizer.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SynchronizedScrollController.h"

@implementation SynchronizedScrollController

@synthesize name;

// -----------------------------------------------------------------
// init
// Initialize the mem browser
// -----------------------------------------------------------------
- (id)init {
    self = [super init];
    if (self) {
        scrolling = NO;
        scrollViews = [[NSMutableArray alloc] init];
    }
    return self;
}

// -----------------------------------------------------------------
// scrollChildBoundsDidChange
// Notification serviced when a synchronized scroll view's bounds have changed
// -----------------------------------------------------------------
- (void)scrollChildBoundsDidChange:(NSNotification *)notification {
    SynchronizedScrollView *curView;
    NSClipView   *curClip;
    NSClipView   *changedContentView = [notification object];
    SynchronizedScrollView *changedScrollView = (SynchronizedScrollView *)[changedContentView superview];
    
    if (!scrolling) {
        scrolling = YES;
        
        NSRect changedRect = [changedContentView documentRect];
        NSRect changedDocVisible = [changedContentView documentVisibleRect];
        NSRect changedVisibleRect = [changedContentView visibleRect];
        NSPoint changedScrollPoint = changedVisibleRect.origin;
        NSPoint changedLastScrollPoint = [changedScrollView lastScrollPoint];
        
        CGFloat lastY = changedLastScrollPoint.y;
        CGFloat newY  = changedScrollPoint.y;
        CGFloat scrollDistance = (newY - lastY);

        if (scrollDistance != 0) {
            for (int i = 0; i < [scrollViews count]; i++) {
                curView = (SynchronizedScrollView *)[scrollViews objectAtIndex:i];
                curClip = [curView contentView];
                
                if (curClip != changedContentView) {
                    
                    NSRect curRect = [curClip documentRect];
                    
                    NSPoint changedBoundsOrigin = changedDocVisible.origin;
                    NSPoint curOffset = [curClip bounds].origin;
                    NSPoint newOffset = curOffset;
                    
                    NSSize changedViewSize = changedRect.size;
                    NSSize curViewSize = curRect.size;
                    
                    CGFloat offset = (scrollDistance / changedViewSize.height) * curViewSize.height;
                    newOffset.y = newOffset.y + scrollDistance;
                    
                    [curView setLastScrollPoint:curOffset];
                    [curClip scrollToPoint:newOffset];
                    [curView reflectScrolledClipView:curClip];
                    [curView setNeedsDisplay:YES];
                }
            }
        }
        
        changedLastScrollPoint.y += scrollDistance;
        
        [changedScrollView setLastScrollPoint:changedLastScrollPoint];
                
        scrolling = NO;
    }
}

// -----------------------------------------------------------------
// registerScrollView
// Registers a scroll view to be synchronized
// -----------------------------------------------------------------
- (void)registerScrollView:(SynchronizedScrollView *)scrollView {
    NSView *synchronizedContentView;
    [scrollViews addObject:scrollView];
    synchronizedContentView = [scrollView contentView];
    [synchronizedContentView setPostsBoundsChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(scrollChildBoundsDidChange:) 
                                                 name:NSViewBoundsDidChangeNotification 
                                               object:synchronizedContentView];
    
}

// -----------------------------------------------------------------
// unregisterScrollView
// Stops synchronizing a particular scroll view
// -----------------------------------------------------------------
- (void)unregisterScrollView:(SynchronizedScrollView *)scrollView {
    NSView *synchronizedContentView = [scrollView contentView];
    
    long loc = [scrollViews indexOfObject:scrollView];
    if (loc != NSNotFound) {
        [scrollViews removeObjectAtIndex:loc];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:NSViewBoundsDidChangeNotification 
                                                      object:synchronizedContentView];
    }
    
    
}

@end
