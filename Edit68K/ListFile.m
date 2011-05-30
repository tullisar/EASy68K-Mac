//
//  ListFile.m
//  Edit68K
//
//  Created by Robert Bartlett-Schneider on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ListFile.h"
#import "NoodleLineNumberView.h"
#import "MarkerLineNumberView.h"

@implementation ListFile

@synthesize textStorage;

//--------------------------------------------------------
// init()
//--------------------------------------------------------
- (id)init {
    self = [super init];
    if (self) {
        [self initTextStorage];
        fontSize = [CONSOLE_FONT pointSize];
        fontName = [CONSOLE_FONT displayName];
    }
    
    return self;
}

// -----------------------------------------------------------------
// awakeFromNib
// Runs when the NIB file has been loaded.
// -----------------------------------------------------------------
- (void)awakeFromNib {    
    [self initCodeEditor];
}


//--------------------------------------------------------
// textStorage() getter for textStorage variable
//--------------------------------------------------------
- (NSTextStorage *)textStorage {
    return [[textStorage retain] autorelease];
}

//--------------------------------------------------------
// setTextStorage() setter for textStorage variable
//--------------------------------------------------------
- (void) setTextStorage:(NSTextStorage *)value {
    if (textStorage != value) {
        if (textStorage) [textStorage release];
        textStorage = [value copy];
    }
}

//--------------------------------------------------------
// initTextStorage()
// initializes the default template
//--------------------------------------------------------
- (void)initTextStorage {
    NSError *error;
    // For now, the template is stored in a file, may move it into memory.
    textStorage = [[NSTextStorage alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"template" withExtension:@"x68"] 
                                             options:nil 
                                  documentAttributes:NULL 
                                               error:&error];
    
    // For the moment, terminate if there's an error and the file is not loaded.
    if (!textStorage) {
        [NSApp presentError:error];
        [NSApp terminate:self];
    }    
    
    [textStorage setFont:CONSOLE_FONT];
}

//--------------------------------------------------------
// initCodeEditor()
// Initializes the line number view of the code editor
//--------------------------------------------------------
- (void)initCodeEditor {
    
    const float LargeNumberForText = 1.0e7;
    NSLayoutManager     *layout;
    NSParagraphStyle    *defStyle;
    NSDictionary        *attributes;
    NSTextStorage       *curText, *newText;
    NSString            *rawText;
    NSRange             textRange;
    
    // Initialize the NSTextView with the NoodleLineNumberView
    lineNumberView = [[[MarkerLineNumberView alloc] initWithScrollView:scrollView] autorelease];
    [scrollView setVerticalRulerView:lineNumberView];
    [scrollView setHasHorizontalRuler:NO];
    [scrollView setHasVerticalRuler:YES];
    [scrollView setRulersVisible:YES];
    [textView setFont:CONSOLE_FONT];
    
    // Make the scroll view non-wrapping
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    NSTextContainer *textContainer = [textView textContainer];
    [textContainer setContainerSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
    [textContainer setWidthTracksTextView:NO];
    [textContainer setHeightTracksTextView:NO];
    [textView setMaxSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
    [textView setHorizontallyResizable:YES];
    [textView setVerticallyResizable:YES];
    [textView setAutoresizingMask:NSViewNotSizable];
    
    // Update paragraphs tyle
    defStyle = [self paragraphStyleForFont:CONSOLE_FONT];
    [textView setDefaultParagraphStyle:defStyle];
    curText  = [self textStorage];
    
    // Get the raw text minus the attributes (to avoid attribues covering only partial range bug)
    textRange = NSMakeRange(0, [curText length]);
    rawText = [curText string];
    newText = [[NSTextStorage alloc] initWithString:rawText];
    
    // Set up the new attributes and apply
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                  CONSOLE_FONT, NSFontAttributeName,
                  [NSColor blackColor], NSForegroundColorAttributeName,
                  defStyle, NSParagraphStyleAttributeName,
                  nil];
    [newText addAttributes:attributes range:textRange];
    [newText fixAttributesInRange:textRange];
    [self setTextStorage:newText];
    [textView setTypingAttributes:attributes];
    
    // Update layout manager to reflect currently visible text
    layout = [textView layoutManager];
    [layout replaceTextStorage:newText];
    [lineNumberView setClientView:[scrollView documentView]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(codeTextDidChange:) name:NSTextDidChangeNotification object:nil];
}

//--------------------------------------------------------
// tabWidthForTextAttributes
//--------------------------------------------------------
- (CGFloat)tabWidthForTextAttributes:(NSDictionary *)attr {
    
    NSMutableString *str;
    NSUserDefaults  *ud;
    NSNumber        *tabNum;
    int             tabSize;
    
    ud = [NSUserDefaults standardUserDefaults];
    tabNum = (NSNumber *)[ud objectForKey:@"tabWidthInSpaces"];
    tabSize = [tabNum intValue];
    
    str = [NSMutableString string];
    for (int i = 0; i < tabSize; i++)
        [str appendString:@" "];
    
    return ([str sizeWithAttributes:attr]).width;
}

//--------------------------------------------------------
// paragraphStyleForFont
//--------------------------------------------------------
- (NSParagraphStyle *)paragraphStyleForFont:(NSFont *)theFont {
    NSMutableParagraphStyle *defStyle;
    defStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
                          theFont, NSFontAttributeName,
                          [NSColor blackColor], NSForegroundColorAttributeName,
                          nil];
    NSMutableArray *tabs = [NSMutableArray arrayWithCapacity:20];
    
    CGFloat tabSize = [self tabWidthForTextAttributes:attr];
    for (int i = 0; i < 20; i++) {
        NSTextTab *tTab = [[NSTextTab alloc] initWithType:NSLeftTabStopType location:((i+1)*tabSize)];
        [tabs addObject:tTab];
    }
    
    [defStyle setTabStops:tabs];
    return defStyle;
}

//--------------------------------------------------------
// codeTextDidChange
//--------------------------------------------------------
- (void)codeTextDidChange:(NSNotification *)notify {
    
    NSLayoutManager     *layout;
    NSParagraphStyle    *newStyle;
    NSDictionary        *attributes;
    NSTextStorage       *curText, *newText;
    NSString            *newName, *rawText;
    NSFont              *realFont;
    CGFloat             newSize;
    NSRange             textRange;
    
    // Get information about the font
    realFont = [textView font];
    newName  = [realFont fontName];
    newSize  = [realFont pointSize];
    curText  = [textView textStorage];
    
    // If font size or name changed, do some work on the tabs!
    if ((newSize != fontSize) || !([newName isEqualToString:fontName])) {
        
        // Get the new paragraph style based on the font
        newStyle = [self paragraphStyleForFont:realFont];
        [textView setDefaultParagraphStyle:newStyle];
        
        // Get the raw text minus the attributes (to avoid attribues covering only partial range bug)
        textRange = NSMakeRange(0, [curText length]);
        rawText = [curText string];
        newText = [[NSTextStorage alloc] initWithString:rawText];
        
        // Set up the new attributes and apply
        attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                      realFont, NSFontAttributeName,
                      [NSColor blackColor], NSForegroundColorAttributeName,
                      newStyle, NSParagraphStyleAttributeName,
                      nil];
        [newText addAttributes:attributes range:textRange];
        [self setTextStorage:newText];
        [textView setDefaultParagraphStyle:newStyle];
        [[textView textStorage] fixAttributesInRange:textRange];
        [textView setTypingAttributes:attributes];
        
        // Update layout manager to reflect currently visible text
        layout = [textView layoutManager];
        [layout replaceTextStorage:newText];
        [lineNumberView setClientView:[scrollView documentView]];
        
        fontSize = newSize;
        fontName = newName;
    }
}

//--------------------------------------------------------
// windowNibName()
// Used to define the xib file associated with this document
//--------------------------------------------------------
- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"ListFile";
}

//--------------------------------------------------------
// windowControllerDidLoadNib()
//--------------------------------------------------------
- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

//--------------------------------------------------------
// dataOfType() used to write files to disk
//--------------------------------------------------------
//- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
//{
//    NSData *data;
//    [self setTextStorage:[textView textStorage]];
//    NSMutableDictionary *dict = [NSDictionary dictionaryWithObject:NSPlainTextDocumentType
//                                                            forKey:NSDocumentTypeDocumentAttribute];
//    [textView breakUndoCoalescing];
//    data = [[self textStorage] dataFromRange:NSMakeRange(0, [[self textStorage] length])
//                          documentAttributes:dict error:outError];
//    
//    
//    return data;
//}

//--------------------------------------------------------
// readFromData() used to open files from disk
//--------------------------------------------------------
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL readSuccess = NO;
    NSTextStorage* fileContents = [[NSTextStorage alloc]
                                   initWithData:data options:NULL documentAttributes:NULL error:outError];
    
    if (fileContents) {
        readSuccess = YES;
        NSString *temp = [fileContents string];
        [fileContents setFont:[NSFont fontWithName:@"Courier" size:11]];
        [self setTextStorage:fileContents];
    }
        
    return readSuccess;
}

//--------------------------------------------------------
// dealloc() 
//--------------------------------------------------------
- (void)dealloc {
    [textStorage release];
    [super dealloc];
}

@end
