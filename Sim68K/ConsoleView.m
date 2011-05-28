/***************************** 68000 SIMULATOR ****************************
 
 File Name: ConsoleView.h
 Version: 1.0 (Mac OS X)
 
 Implementation file for the NSView sublcass ConsoleView. Used by the simulator
 IO window to handle I/O from the 68000 program.
 
 The routines are :
 
 textIn
 charIn
 textOut
 textOutCR
 charOut
 
 Created:  2011-04-15
           Robert Bartlett-Schneider
 
 TODO: Support paste command when text input is active during program execution
 
 ***************************************************************************/

#import "ConsoleView.h"
#import "Simulator.h"
#import "NSTextView-TextManipulation.h"
#include "extern.h"

@implementation ConsoleView

// -----------------------------------------------------------------
// init
// Default initialization for the textView
// -----------------------------------------------------------------
- (id)init {
    self = [super init];
    if (self) {
        row = col = textX = textY = x = y = 0;
        for (int i = 0; i < KEYBUF_SIZE; i++) {
            eventKeyBuffer[i] = '\0';
            keyBuf[i] = '\0';
        }
        keyI = 0;
        inputMode = NO;
        charInput = NO;
        
        promptFlash = [NSTimer timerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(promptTimer:)
                                            userInfo:nil
                                             repeats:YES];
    }
    return self;
}


// -----------------------------------------------------------------
// initWithFrame
// Default initialization for the textView when initialized with a rect
// -----------------------------------------------------------------
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        row = col = textX = textY = x = y = 0;
        for (int i = 0; i < KEYBUF_SIZE; i++) {
            eventKeyBuffer[i] = '\0';
            keyBuf[i] = '\0';
        }
        keyI = 0;
        inputMode = NO;
        charInput = NO;
        
        promptFlash = [NSTimer timerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(promptTimer:)
                                            userInfo:nil
                                             repeats:YES];
    }
    return self;
}

// -----------------------------------------------------------------
// awakeFromNib
// Called when loaded from the nib file
// -----------------------------------------------------------------
- (void)awakeFromNib {
    row = col = textX = textY = x = y = 0;
    for (int i = 0; i < KEYBUF_SIZE; i++) {
        eventKeyBuffer[i] = '\0';
        keyBuf[i] = '\0';
    }
    keyI = 0;
    inputMode = NO;
    charInput = NO;
    
    promptFlash = [NSTimer timerWithTimeInterval:1.0
                                          target:self
                                        selector:@selector(promptTimer:)
                                        userInfo:nil
                                         repeats:YES]; 
}

// -----------------------------------------------------------------
// promptTimer
// Paint method for updating display if necesary
// -----------------------------------------------------------------
- (void)promptTimer {
    [self invertTextColorForRange:[self lastCharRange]];
}

// -----------------------------------------------------------------
// drawRect
// Paint method for updating display if necesary
// -----------------------------------------------------------------
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

// -----------------------------------------------------------------
// keyDown
// Overrides the keyDown to handle text input
// -----------------------------------------------------------------
- (void)keyDown:(NSEvent *)theEvent {
    sprintf(eventKeyBuffer, "%s", [[theEvent characters] cStringUsingEncoding:NSUTF8StringEncoding]);
    char key = eventKeyBuffer[0];
    if (inputMode) {
        // if Enter key, limit reached, or char input
        if (key == '\r' || keyI >= 79 || charInput) {
            // TODO: Erase prompt
            if (charInput) {
                *inChar = key;                                  // get key
                charInput = NO;
                if (keyboardEcho) {
                    [self charOut:key];
                    if (key == '\r' && inputLFdisplay) {        // if CR and LF display wanted
                        [self charOut:'\n'];                    // do LF
                    }
                }
            }
            else {
                if (inputLFdisplay) {
                    [self charOut:'\n'];
                }
                keyBuf[keyI] = '\0';                            // terminate input buffer
                if (inputNumber == NULL) {                      // if string input
                    for (int i = 0; i < keyI; i++)              // put string in 68000 memory at userBuf
                        mem_put(keyBuf[i], (int)memDistance(&userBuf[i], &memory[0], BYTE_MASK), BYTE_MASK);
                    *inputLength = keyI;                        // length of input string to D1
                }
                else {                                          // else numeric input
                    strcpy(inputBuf, keyBuf);                   // copy to sim68K inputBuf
                    *inputLength = keyI;                        // length of input string to D1
                    *inputNumber = atoi(inputBuf);              // convert string to int
                }
            }
            inputMode = NO;
            trapInput = NO;
            if (trace) {
                // TODO: Enable debug
                // TODO: Enable hardware
                [[appDelegate simulator] displayReg];
            }
            
            if (inputPrompt) {
                [promptFlash invalidate];
            }
        }
        else if (key == kBackspaceKey || key == kDeleteKey) {   // if backspace or delete key
            keyI--;                                             // remove one char from buffer
            if (keyI < 0)
                keyI = 0;
            else {
                keyBuf[keyI] = '\0';                            // temporarily terminate input buffer
                if (keyboardEcho)
                    [self removeLastChar];
            }
        }
        else {
            keyBuf[keyI++] = key;                               // get key
            keyBuf[keyI] = '\0';                                // temporarily terminate input buffer
            if (keyboardEcho) {
                [self charOut:key];
                if (logging && OlogFlag == TEXTONLY) {
                    // TODO: Print to log file
                    // fprintf(OlogFile,"%c",keybuf[keyI-1];
                    // fflush(OlogFile);
                }
            }
        }
    }
    else {
        pendingKey = key;
    }
}


// -----------------------------------------------------------------
// textIn
// Allows for text input!
// -----------------------------------------------------------------
- (void)textIn:(char *)str sizePtr:(long *)size regNum:(long *)inNum {
    userBuf     = str;
    inputLength = size;
    inputNumber = inNum;
    keyI        = 0;
    inputMode   = YES;
    
    if (pendingKey) {
        NSEvent *formKeyPress = [NSEvent keyEventWithType:NSKeyDown 
                                                 location:NSMakePoint(0, 0) 
                                            modifierFlags:0 
                                                timestamp:nil
                                             windowNumber:0
                                                  context:nil 
                                               characters:[NSString stringWithFormat:@"%c",pendingKey]
                              charactersIgnoringModifiers:[NSString stringWithFormat:@"%c",pendingKey]
                                                isARepeat:NO 
                                                  keyCode:0];
        [self keyDown:formKeyPress];
        pendingKey = 0;
    }
    
    if (inputPrompt) {
        [[NSRunLoop currentRunLoop] addTimer:promptFlash 
                                     forMode:NSRunLoopCommonModes];
    }
}

// -----------------------------------------------------------------
// charIn
// Reads a single character into the address pointed to by ch
// -----------------------------------------------------------------
- (void)charIn:(char *)ch {
    char str[2];
    long size;
    if (pendingKey) {
        *ch = pendingKey;
        if (keyboardEcho) {
            if (pendingKey != kBackspaceKey || pendingKey != kDeleteKey)
                [self charOut:pendingKey];
            if (pendingKey == '\r')
                [self charOut:'\n'];
        }
        pendingKey = 0;
        trapInput = NO;
        return;
    }
    inputCh = ch;
    charInput = YES;
    [self textIn:str sizePtr:&size regNum:NULL];
}

// -----------------------------------------------------------------
// textOut
// Outputs a string to the I/O Window without a newline
// -----------------------------------------------------------------
- (void)textOut:(char *)str {
    // TODO: Dispatch to main thread to be thread safe
    NSString *line = [NSString stringWithFormat:@"%s",str];

    [self appendString:line 
              withFont:CONSOLE_FONT 
              andColor:CONSOLE_FONT_COLOR];
    [self setNeedsDisplay:YES];
}

// -----------------------------------------------------------------
// textOutCR
// Outputs a string to the I/O Window with a newline
// -----------------------------------------------------------------
- (void)textOutCR:(char *)str {
    char buf[256];
    sprintf(buf, "%s\n", str);
    [self textOut:buf];
}
    
// -----------------------------------------------------------------
// charOut
// Outputs a single character to the console
// -----------------------------------------------------------------
- (void)charOut:(char)ch {
    NSString *strCh;
    switch (ch) {
        case '\a':                  // if Bell
            // TODO: Beep
            break;
        case '\b':                  // if Backspace
            [self removeLastChar];
            break;
        case '\f':                  // if Formfeed
            // TODO: Form feed
            break;
        case '\n':                  // if LF
            [self appendString:@"\n" 
                      withFont:CONSOLE_FONT
                      andColor:CONSOLE_FONT_COLOR];
//            if (logging && OlogFlag == TEXTONLY) { // if logging output
//                fprintf(OlogFile,"\n");
//                fflush(OlogFile);         // write all bufferred data to file
//            }
            break;
        case '\r':                  // if CR
            [self appendString:@"\n" 
                      withFont:CONSOLE_FONT
                      andColor:CONSOLE_FONT_COLOR];
            break;
        case '\t':                  // if Tab
            [self appendString:@"\t" 
                      withFont:CONSOLE_FONT
                      andColor:CONSOLE_FONT_COLOR];          
            break;
        case '\v':                  // if Vertical tab
            // TODO: Vertical tab
            break;
        default:
            if (ch >= ' ') {          // if not control char
                strCh = [NSString stringWithFormat:@"%c",ch];
                [self appendString:strCh
                          withFont:CONSOLE_FONT
                          andColor:CONSOLE_FONT_COLOR];
//                if (logging && OlogFlag == TEXTONLY) {      // if logging output
//                    fprintf(OlogFile,"%c",ch);
//                    fflush(OlogFile);         // write all bufferred data to file
//                }
            }
    }
    
    [self setNeedsDisplay:YES];
}

@end
