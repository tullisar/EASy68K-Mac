//
//  MemBrowserScrollSynchronizer.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SynchronizedScrollView.h"

@interface MemBrowserScrollSynchronizer : NSObject {

    BOOL scrolling;
    NSMutableArray *scrollViews;
    
}

- (void)scrollChildBoundsDidChange:(NSNotification *)notification;
- (void)registerScrollView:(SynchronizedScrollView *)scrollView;
- (void)unregisterScrollView:(SynchronizedScrollView *)scrollView;

@end
