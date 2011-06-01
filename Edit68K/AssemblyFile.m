//
//  AssemblyFile.m
//  Edit68K
//
//  Created by Robert Bartlett-Schneider on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AssemblyFile.h"
#import "NoodleLineNumberView.h"
#import "MarkerLineNumberView.h"

@implementation AssemblyFile

@synthesize textStorage, noErrors, errorDisplay;

//--------------------------------------------------------
// init()
//--------------------------------------------------------
- (id)init {
    self = [super init];
    if (self) {
        [self initTextStorage];
        savedYet = NO;
        diskFile = NO;
        noErrors = YES;
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
    if (!diskFile)
        [self initTextStorage];
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
    return @"AssemblyFile";
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
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSData *data;
    [self setTextStorage:[textView textStorage]];
    NSMutableDictionary *dict = [NSDictionary dictionaryWithObject:NSPlainTextDocumentType
                                                            forKey:NSDocumentTypeDocumentAttribute];
    [textView breakUndoCoalescing];
    data = [[self textStorage] dataFromRange:NSMakeRange(0, [[self textStorage] length])
                     documentAttributes:dict error:outError];
    
    savedYet = YES;
    
    return data;
}

//--------------------------------------------------------
// readFromData() used to open files from disk
//--------------------------------------------------------
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
//    NSLayoutManager     *layout;
//    NSParagraphStyle    *defStyle;
//    NSDictionary        *attributes;
//    NSTextStorage       *curText, *newText;
//    NSString            *rawText;
//    NSRange             textRange;
    
    BOOL readSuccess = NO;
    NSTextStorage* fileContents = [[NSTextStorage alloc]
                                  initWithData:data options:NULL documentAttributes:NULL error:outError];
    
    if (fileContents) {
        readSuccess = YES;
        NSString *temp = [fileContents string];
        [fileContents setFont:[NSFont fontWithName:@"Courier" size:11]];
        [self setTextStorage:fileContents];
        diskFile = YES;
//        // Update paragraphs tyle
//        defStyle = [self paragraphStyleForFont:CONSOLE_FONT];
//        [textView setDefaultParagraphStyle:defStyle];
//        curText  = fileContents;
//        
//        // Get the raw text minus the attributes (to avoid attribues covering only partial range bug)
//        textRange = NSMakeRange(0, [curText length]);
//        rawText = [curText string];
//        newText = [[NSTextStorage alloc] initWithString:rawText];
//        
//        // Set up the new attributes and apply
//        attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                      CONSOLE_FONT, NSFontAttributeName,
//                      [NSColor blackColor], NSForegroundColorAttributeName,
//                      defStyle, NSParagraphStyleAttributeName,
//                      nil];
//        [newText addAttributes:attributes range:textRange];
//        [self setTextStorage:newText];
//        [textView setDefaultParagraphStyle:defStyle];
//        [[textView textStorage] fixAttributesInRange:textRange];
//        [textView setTypingAttributes:attributes];
//        
//        // Update layout manager to reflect currently visible text
//        layout = [textView layoutManager];
//        [layout replaceTextStorage:newText];
//        [lineNumberView setClientView:[scrollView documentView]];
        
    }
    
    savedYet = YES;
    
    return readSuccess;
}

//--------------------------------------------------------
// assemble() assemble's the current document
//--------------------------------------------------------
- (IBAction)assemble:(id)sender {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if (!savedYet) {
        NSString *description = NSLocalizedString(@"Please save the file before attempting to assemble it.", @"");
        NSAlert *saveFileFirst = [[[NSAlert alloc] init] autorelease];
        [saveFileFirst setMessageText:description];
        [saveFileFirst addButtonWithTitle:@"Okay"];
        [saveFileFirst setAlertStyle:NSWarningAlertStyle];
        [saveFileFirst runModal];
    } else {
        char inputFile[256];
        char tempFile[256];
        
        NSString *path = [[self fileURL] path];
        const char *cPath = [path cStringUsingEncoding:NSASCIIStringEncoding];
        
        sprintf(inputFile, "%s", cPath);
        strcpy(tempFile, "edit68k-XXXXXX");
        
        listFlag = ([ud boolForKey:@"generateListFile"] ? true : false);
        objFlag  = ([ud boolForKey:@"generateSRecord"] ? true : false);
        CEXflag  = ([ud boolForKey:@"listFileConstantsEpanded"] ? true : false);
        BITflag  = ([ud boolForKey:@"assembleBitFieldInstructions"] ? true : false);
        CREflag  = ([ud boolForKey:@"listFileCrossReference"] ? true : false);
        MEXflag  = ([ud boolForKey:@"listFileMacrosExpanded"] ? true : false);
        SEXflag  = ([ud boolForKey:@"listFileStructuredExpanded"] ? true : false);
        WARflag  = ([ud boolForKey:@"showWarnings"] ? true : false);
        
        if (mktemp(tempFile) == NULL) {
            [self setNoErrors:NO];
            [self setErrorDisplay:[NSString stringWithFormat:@"There was an error during the assembly process. See console output."]];
            NSLog(@"%@",@"Error creating temporary file via mkstemp()");
        } else {
            if ( assembleFile(inputFile, tempFile, inputFile) != NORMAL) {
                [self setNoErrors:NO];
                [self setErrorDisplay:[NSString stringWithFormat:@"Errors: %d Warnings: %d",errorCount,warningCount]];
                [sheetController openSheet:self];
            } else {
                if (errorCount > 0 || warningCount > 0) {
                    [self setErrorDisplay:[NSString stringWithFormat:@"Errors: %d Warnings: %d",errorCount,warningCount]];
                    [self setNoErrors:NO];
                    [sheetController openSheet:self];
                } else {
                    [self setErrorDisplay:[NSString stringWithFormat:@"Assembly complete. No errors detected"]];
                    [self setNoErrors:YES];
                    [sheetController openSheet:self];
                }
            }
        }
    }
}

//--------------------------------------------------------
// initialize()
// Initialize the default values for Shared User Defaults
//--------------------------------------------------------
+ (void)initialize {
    [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithBool:YES], @"generateListFile",
      [NSNumber numberWithBool:YES], @"generateSRecord",
      [NSNumber numberWithBool:NO], @"showWarnings",
      [NSNumber numberWithBool:NO], @"autoSaveBeforeAssembling",
      [NSNumber numberWithBool:NO], @"assembleBitFieldInstructions",
      [NSNumber numberWithBool:NO], @"listFileCrossReference",
      [NSNumber numberWithBool:NO], @"listFileStructuredExpanded",
      [NSNumber numberWithBool:NO], @"listFileConstantsExpanded",
      [NSNumber numberWithBool:NO], @"listFileMacrosExpanded",
      [NSNumber numberWithInt:4], @"tabWidthInSpaces",
      [NSNumber numberWithInt:kTabTypeFixed], @"tabType",
      nil]];
    
    listFlag = true;
    objFlag = true;
    CEXflag = false;
    BITflag = false;
    CREflag = false;
    MEXflag = false;
    SEXflag = false;
    WARflag = false;    
}

//--------------------------------------------------------
// printShowingPrintPanel
// Called when the document is printed by the application
//--------------------------------------------------------
- (void)printShowingPrintPanel:(BOOL)showPanels {
    
    NSPrintOperation *op = [NSPrintOperation printOperationWithView:textView 
                                                          printInfo:[self printInfo]];
    
    [op setShowPanels:showPanels];
    if (showPanels) {
        // add accessory view if needed
    } 
    
    [self runModalPrintOperation:op
                        delegate:nil 
                  didRunSelector:NULL
                     contextInfo:NULL];
}

//--------------------------------------------------------
// shouldCloseSheet
// Called when the sheet window is closed.
//--------------------------------------------------------
- (BOOL)shouldCloseSheet:(id)sender {
 
    NSButton *sendingButton = (NSButton *)sender;
    NSString *label = [sendingButton title];
    NSString *xFile = [[self fileURL] path];
    NSString *lFile = [[xFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"L68"];
    NSString *sFile = [[xFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"X68"];
    
    if ([label isEqualToString:@"Execute"])
        [[NSWorkspace sharedWorkspace] openFile:sFile withApplication:@"Sim68K"];
    else if ([label isEqualToString:@"Load Listfile"])
        [[NSWorkspace sharedWorkspace] openFile:lFile];
    
    return YES;
    
}


//--------------------------------------------------------
// dealloc() 
//--------------------------------------------------------
- (void)dealloc {
    [textStorage release];
    [super dealloc];
}

@end
