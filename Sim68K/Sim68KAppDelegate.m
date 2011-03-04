//
//  Sim68KAppDelegate.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 2/27/11.
//

#import "Sim68KAppDelegate.h"
#import "NoodleLineNumberView.h"
#import "NoodleLineNumberMarker.h"
#import "MarkerLineNumberView.h"
#import "Simulator.h"

//#import <BWToolkitFramework/BWToolkitFramework.h>

@implementation Sim68KAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
}

- (void)awakeFromNib 
{
    
    // Initialize the NSTextView with the NoodleLineNumberView
    lineNumberView = [[MarkerLineNumberView alloc] initWithScrollView:scrollView];
    [scrollView setVerticalRulerView:lineNumberView];
    [scrollView setHasHorizontalRuler:NO];
    [scrollView setHasVerticalRuler:YES];
    [scrollView setRulersVisible:YES];
    [scriptView setFont:[NSFont fontWithName:@"Courier" size:11]];
    
    // Initialize the simulator

    
}

@end
