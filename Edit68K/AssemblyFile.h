//
//  AssemblyFile.h
//  Edit68K
//
//  Created by Robert Bartlett-Schneider on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CodeEditor.h"
#include "asm.h"
#include "Edit68KMac.h"
#import <BWToolkitFramework/BWToolkitFramework.h>

extern bool listFlag;
extern bool objFlag;
extern bool CEXflag;
extern bool BITflag;
extern bool CREflag;
extern bool MEXflag;
extern bool SEXflag;
extern bool WARflag;
extern int errorCount;
extern int warningCount;

extern int assembleFile(char fileName[], char tempName[], char workName[]);

@class NoodleLineNumberView;

@interface AssemblyFile : NSDocument {
    
    IBOutlet BWSheetController *sheetController;
    
    IBOutlet CodeEditor *textView;
    IBOutlet NSScrollView *scrollView;
    NoodleLineNumberView *lineNumberView;
    
    NSTextStorage *textStorage;
    
    BOOL diskFile;
    BOOL savedYet;
    BOOL noErrors;
    NSString *errorDisplay;
    
    CGFloat fontSize;
    NSString *fontName;
    
}

@property (readwrite, retain) NSTextStorage *textStorage;
@property (retain) NSString *errorDisplay;
@property (assign) BOOL noErrors;

- (NSTextStorage *)textStorage;
- (void)setTextStorage:(NSTextStorage *) value;
- (void)initTextStorage;
- (void)initCodeEditor;
- (NSParagraphStyle *)paragraphStyleForFont:(NSFont *)theFont;
- (void)codeTextDidChange:(NSNotification *)notify;
- (CGFloat)tabWidthForTextAttributes:(NSDictionary *)attr;
- (IBAction)assemble:(id)sender;
- (BOOL)shouldCloseSheet:(id)sender;

@end
