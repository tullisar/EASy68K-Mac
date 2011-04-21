//
//  TripleSynchronizedScrollView.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
// Code based on following synchronized scroll view example:
// http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/NSScrollViewGuide/Articles/SynchroScroll.html

#import "TripleSynchronizedScrollView.h"

@implementation TripleSynchronizedScrollView

// -----------------------------------------------------------------
// setPartnerA
// Sets this synchronized scroll view's first partner
// -----------------------------------------------------------------
- (void)setPartnerA:(NSScrollView *)scrollView {
    NSView *synchronizedContentView;
    
    // don't retain the watched view, because we assume that it will
    // be retained by the view hierarchy for as long as we're around.
    partnerA = scrollView;
    
    // get the content view of the
    synchronizedContentView = [partnerA contentView];
    
    // Make sure the watched view is sending bounds changed
    // notifications (which is probably does anyway, but calling
    // this again won't hurt).
    [synchronizedContentView setPostsBoundsChangedNotifications:YES];
    
    // a register for those notifications on the synchronized content view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(synchronizedViewContentBoundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:synchronizedContentView];  
}

// -----------------------------------------------------------------
// setPartnerB
// Sets this synchronized scroll view's second partner
// -----------------------------------------------------------------
- (void)setPartnerB:(NSScrollView *)scrollView {
    NSView *synchronizedContentView;
    
    // don't retain the watched view, because we assume that it will
    // be retained by the view hierarchy for as long as we're around.
    partnerB = scrollView;
    
    // get the content view of the
    synchronizedContentView = [partnerB contentView];
    
    // Make sure the watched view is sending bounds changed
    // notifications (which is probably does anyway, but calling
    // this again won't hurt).
    [synchronizedContentView setPostsBoundsChangedNotifications:YES];
    
    // a register for those notifications on the synchronized content view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(synchronizedViewContentBoundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:synchronizedContentView];  
}

// -----------------------------------------------------------------
// stopSynchronizing
// Disable's synchronizing for this scroll view
// -----------------------------------------------------------------
- (void)stopSynchronizing {
    if (partnerA != nil) {
        NSView* synchronizedContentView = [partnerA contentView];
        
        // remove any existing notification registration
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSViewBoundsDidChangeNotification
                                                      object:synchronizedContentView];
        
        // set synchronizedScrollView to nil
        partnerA=nil;
    }
    if (partnerB != nil) {
        NSView* synchronizedContentView = [partnerB contentView];
        
        // remove any existing notification registration
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSViewBoundsDidChangeNotification
                                                      object:synchronizedContentView];
        
        // set synchronizedScrollView to nil
        partnerB=nil;
    }   
}

// -----------------------------------------------------------------
// synchronizedViewContentsBoundsDidChange
// Notification when synchronized views are scrolled
// -----------------------------------------------------------------
- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification {
    // get the changed content view from the notification
    NSClipView *changedContentView=[notification object];
    
    // get the origin of the NSClipView of the scroll view that
    // we're watching
    NSPoint changedBoundsOrigin = [changedContentView documentVisibleRect].origin;;
    
    // get our current origin
    NSPoint curOffset = [[self contentView] bounds].origin;
    NSPoint newOffset = curOffset;
    
    // scrolling is synchronized in the vertical plane
    // so only modify the y component of the offset
    newOffset.y = changedBoundsOrigin.y;
    
    // if our synced position is different from our current
    // position, reposition our content view
    if (!NSEqualPoints(curOffset, changedBoundsOrigin))
    {
        // note that a scroll view watching this one will
        // get notified here
        [[self contentView] scrollToPoint:newOffset];
        // we have to tell the NSScrollView to update its
        // scrollers
        [self reflectScrolledClipView:[self contentView]];
    }
}


@end
