//
//  MyDocument.m
//  EASy68K
//
//  Created by Robert Bartlett-Schneider on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AssemblyFile.h"

@implementation AssemblyFile

@synthesize textStorage;

- (id)init
{
    self = [super init];
    if (self) {
        
        [self initTextStorage];
    
        listFlag = true;
        objFlag = true;
    }
    return self;
}

// Customized getter method for textStorage
- (NSTextStorage *)textStorage {
    return [[textStorage retain] autorelease];
}

// Customized setter method for textStorage
- (void) setTextStorage:(NSTextStorage *)value {
    if (textStorage != value) {
        if (textStorage) [textStorage release];
        textStorage = [value copy];
    }
}

/* Initializes the textStorage which will be loaded with the template file */
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
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"AssemblyFile";
}



- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSData *data;
    [self setTextStorage:[textView textStorage]];
    NSMutableDictionary *dict = [NSDictionary dictionaryWithObject:NSPlainTextDocumentType
                                                            forKey:NSDocumentTypeDocumentAttribute];
    [textView breakUndoCoalescing];
    data = [[self textStorage] dataFromRange:NSMakeRange(0, [[self textStorage] length])
                     documentAttributes:dict error:outError];
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL readSuccess = NO;
    
//    NSTextStorage*fileContents = [[NSAttributedString alloc]
//                                        initWithData:data options:NULL documentAttributes:NULL
//                                        error:outError];
    NSTextStorage* fileContents = [[NSTextStorage alloc]
                                  initWithData:data options:NULL documentAttributes:NULL error:outError];
    
    if (fileContents) {
        readSuccess = YES;
        [self setTextStorage:fileContents];
        [fileContents release];
    }
    return readSuccess;
}

- (void)assemble {
    [self displayName];
}


- (void)dealloc {
    [textStorage release];
    [super dealloc];
}

@end
