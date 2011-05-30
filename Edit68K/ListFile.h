//
//  ListFile.h
//  Edit68K
//
//  Created by Robert Bartlett-Schneider on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CodeEditor.h"
#import "Edit68KMac.h"

@class NoodleLineNumberView;

@interface ListFile : NSDocument {
    
    IBOutlet CodeEditor *textView;
    IBOutlet NSScrollView *scrollView;
    NoodleLineNumberView *lineNumberView;
    
    NSTextStorage *textStorage;

    CGFloat fontSize;
    NSString *fontName;
    
}

@property (readwrite, retain) NSTextStorage *textStorage;

- (NSTextStorage *)textStorage;
- (void)setTextStorage:(NSTextStorage *) value;
- (void)initTextStorage;
- (void)initCodeEditor;
- (NSParagraphStyle *)paragraphStyleForFont:(NSFont *)theFont;
- (void)codeTextDidChange:(NSNotification *)notify;
- (CGFloat)tabWidthForTextAttributes:(NSDictionary *)attr;

@end
