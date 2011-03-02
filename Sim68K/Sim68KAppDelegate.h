//
//  Sim68KAppDelegate.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NoodleLineNumberView;

@interface Sim68KAppDelegate : NSObject {
// @interface Sim68KAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet NSScrollView   *scrollView;
    IBOutlet NSTextView     *scriptView;
	NoodleLineNumberView	*lineNumberView;
    
}

@property (assign) IBOutlet NSWindow *window;

@end
