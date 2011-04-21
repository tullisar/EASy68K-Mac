//
//  TripleSynchronizedScrollView.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TripleSynchronizedScrollView : NSScrollView {
    NSScrollView* partnerA;
    NSScrollView* partnerB;
}

- (void)setPartnerA:(NSScrollView *)scrollView;
- (void)setPartnerB:(NSScrollView *)scrollView;
- (void)stopSynchronizing;
- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification;

@end
