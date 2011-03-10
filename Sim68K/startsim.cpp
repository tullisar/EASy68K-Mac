/***************************** 68000 SIMULATOR ****************************
 
 File Name: startsim.cpp
 Version: 1.0 (Mac OS X)
 
 This file contains the function 'initSim()'
 
 Modified: Chuck Kelly
 Monroe County Community College
 http://www.monroeccc.edu/ckelly
 
 Modified: Robert Bartlett-Schneider
           2011-03-03
           robert@savetherobots.org
 
***************************************************************************/

#include <stdio.h>
#include <iostream>
#include "extern.h"
#include "var.h"

void scrshow(); 	/* update register display */
extern bool inputMode;
extern bool disableKeyCommands;  // defined in SIM68Ku

void initSim()                   // initialization for the simulator
{
    int	i;

    // MARK: GUI: GUI initialization will be done elsewhere
    
    inputMode = false;
    pendingKey = 0;               // clear pendingKey
    
    runMode = false;
    lbuf[0] = '\0';		/* initialize to prevent memory access violations */
    wordptr[0] = lbuf;
    for (i = 0; i <= 7; i++)
        A[i] = D[i] = 0;
    cycles = 0;
    SR = 0x2000;
    A[7] = 0x00FF0000;            // user stack
    A[8] = 0x01000000;            // supervisor stack
    OLD_PC = -1;                  // set different from 'PC' and 'cycles'
    trace = sstep = false;
    stopInstruction = false;
    stepToAddr = 0;               // clear step
    runToAddr = 0;                // clear runTo
    scrshow();
    keyboardEcho = true;          // true, EASy68K input is echoed (default)
    inputPrompt = true;           // true, display prompt during input (default)
    inputLFdisplay = true;
    
    for (i=0; i<MAXFILES; i++) {  // clear file structures
        files[i].fp = NULL;
    }
    
    irq = 0;                      // reset IRQ flags
    // MARK: HARDWARE: Disable Auto interrupt timers
    // Hardware->autoIRQoff();       // turn off auto interrupt timers
    hardReset = false;
    
    // Form1->setMenuActive();       // enable some menu items
    // Hardware->enable();
    FullScreenMonitor = 0;
    
    mouseX = 0;
    mouseY = 0;
    mouseLeft = false;
    mouseRight = false;
    mouseMiddle = false;
    mouseDouble = false;
    keyShift = false;
    keyAlt = false;
    keyCtrl =false;
    
    mouseXUp = 0;
    mouseYUp = 0;
    mouseLeftUp = false;
    mouseRightUp = false;
    mouseMiddleUp = false;
    mouseDoubleUp = false;
    keyShiftUp = false;
    keyAltUp = false;
    keyCtrlUp = false;
    
    mouseXDown = 0;
    mouseYDown = 0;
    mouseLeftDown = false;
    mouseRightDown = false;
    mouseMiddleDown = false;
    mouseDoubleDown = false;
    keyShiftDown = false;
    keyAltDown = false;
    keyCtrlDown = false;
    mouseDownIRQ = 0;
    mouseUpIRQ = 0;
    mouseMoveIRQ = 0;
    keyDownIRQ = 0;
    keyUpIRQ = 0;
    
    // MARK: GUI: More GUI initialization done elsewhere now
//    simIO->ResetSounds(); // stop all playing sounds and clear sound memory
//    
//    Form1->restoreMenuTask19();
//    
//    netCloseSockets();    // close network sockets
}


void scrshow() 	        // update register display
{
//    String str;
//    Form1->regD0->Text = str.sprintf("%08lX",D[0]);
//    Form1->regD1->Text = str.sprintf("%08lX",D[1]);
//    Form1->regD2->Text = str.sprintf("%08lX",D[2]);
//    Form1->regD3->Text = str.sprintf("%08lX",D[3]);
//    Form1->regD4->Text = str.sprintf("%08lX",D[4]);
//    Form1->regD5->Text = str.sprintf("%08lX",D[5]);
//    Form1->regD6->Text = str.sprintf("%08lX",D[6]);
//    Form1->regD7->Text = str.sprintf("%08lX",D[7]);
//    Form1->regA0->Text = str.sprintf("%08lX",A[0]);
//    Form1->regA1->Text = str.sprintf("%08lX",A[1]);
//    Form1->regA2->Text = str.sprintf("%08lX",A[2]);
//    Form1->regA3->Text = str.sprintf("%08lX",A[3]);
//    Form1->regA4->Text = str.sprintf("%08lX",A[4]);
//    Form1->regA5->Text = str.sprintf("%08lX",A[5]);
//    Form1->regA6->Text = str.sprintf("%08lX",A[6]);
//    Form1->regA7->Text = str.sprintf("%08lX",A[a_reg(7)]);
//    Form1->regUS->Text = str.sprintf("%08lX",A[7]);
//    Form1->regA8->Text = str.sprintf("%08lX",A[8]);
//    Form1->regPC->Text = str.sprintf("%08lX",PC);
//    if (cycles > 0xFFFFFFFFFFFF)
//        Form1->cyclesDisplay->Caption = "Overflow";
//    else
//        Form1->cyclesDisplay->Caption = str.sprintf("%u",cycles);
//    
//    // print each bit of SR
//    str = "";
//    for (int j=15;j>=0;j--)
//    {
//        if ((0x1 << j) & SR)
//            str += "1";       //Form1->regSR->EditText[j] = '1';
//        else
//            str += "0";       //Form1->regSR->EditText[j] = '0';
//    }
//    Form1->regSR->Text = str;
//    
//    Form1->highlight();              // highlight the instruction
//    Form1->ListBox1->Repaint();
//    StackFrm->updateDisplay();
//    MemoryFrm->Repaint();
    
}