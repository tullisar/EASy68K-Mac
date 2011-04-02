//
//  ConsoleView.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ConsoleView : NSTextView {

    char pendingKeyChar[2];
    BOOL inputEnabled;
    int  inputIndex;
    char *inBuf;
    long *inSize;
    long *inDest;
    
}

-(void)textIn:(char *)str sizePtr:(long *)size regNum:(long *)inNum;
-(void)charIn:(char *)ch;
-(void)textOut:(char *)str;
-(void)textOutCR:(char *)str;

// Necessary
//__fastcall TsimIO(TComponent* Owner);
//__fastcall ~TsimIO();
//void __fastcall displayFileDialog(long *mode, int A1, int A2, int A3, short *result);
//void __fastcall clearKeys();
//void __fastcall BringToFront();
//void __fastcall setTextSize();
//void __fastcall textOut(AnsiString str);
//void __fastcall textOutCR(AnsiString str);
//void __fastcall setWindowSize(unsigned short width, unsigned short height);
//void __fastcall getWindowSize(unsigned short &width, unsigned short &height);
//void __fastcall setFontProperties(int c, int s);
//void __fastcall gotorc(int x, int y);
//void __fastcall getrc(short* d1);
//void __fastcall getCharAt(unsigned short r, unsigned short c, char* d1);
//void __fastcall textIn(char *, long *, long *);
//void __fastcall charIn(char *ch);
//void __fastcall charOut(char ch);
//void __fastcall doCRLF();
//void __fastcall scroll();
//void __fastcall scrollRect(ushort r, ushort c, ushort w, ushort h, ushort dir);
//void __fastcall erasePrompt();
//void __fastcall clear();
//void __fastcall playSound(char *fileName, short *result);
//void __fastcall loadSound(char *fileName, int waveIndex);
//void __fastcall playSoundMem(int waveIndex, short *result);
//void __fastcall controlSound(int control, int waveIndex, short *result);
//void __fastcall playSoundDX(char *fileName, short *result);
//void __fastcall loadSoundDX(char *fileName, int waveIndex, short *result);
//void __fastcall playSoundMemDX(int waveIndex, short *result);
//void __fastcall stopSoundMemDX(int waveIndex, short *result);
//void __fastcall controlSoundDX(int control, int waveIndex, short *result);
//void __fastcall drawPixel(int x, int y);
//int  __fastcall getPixel(int x, int y);
//void __fastcall line(int x1, int y1, int x2, int y2);
//void __fastcall lineTo(int x, int y);
//void __fastcall moveTo(int x, int y);
//void __fastcall setLineColor(int c);
//void __fastcall setFillColor(int c);
//void __fastcall rectangle(int x1, int y1, int x2, int y2);
//void __fastcall ellipse(int x1, int y1, int x2, int y2);
//void __fastcall floodFill(int x1, int y1);
//void __fastcall unfilledRectangle(int x1, int y1, int x2, int y2);
//void __fastcall unfilledEllipse(int x1, int y1, int x2, int y2);
//void __fastcall setDrawingMode(int m);
//void __fastcall setPenWidth(int w);
//void __fastcall getKeyState(long *);
//bool fullScreen;
//void __fastcall setupWindow();
//void __fastcall drawText(AnsiString str, int x, int y);
//bool InitDirectXAudio(HWND hwnd);
//bool LoadSegment(HWND hwnd, char *filename, IDirectMusicSegment8* &dmSeg);
//void PlaySegment(IDirectMusicPerformance8* dmPerf, IDirectMusicSegment8* dmSeg);
//void PlaySegmentLoop(IDirectMusicPerformance8* dmPerf, IDirectMusicSegment8* dmSeg);
//void StopSegment(IDirectMusicPerformance8* dmPerf, IDirectMusicSegment8* dmSeg);
//void TsimIO::ResetSounds();
//void CloseDown(IDirectMusicPerformance8* dmPerf);
//
//void __fastcall closeAllComm();
//void __fastcall initComm(int cid, char *portName, short *result);
//void __fastcall setCommParams(int cid, int settings, short *result);
//void __fastcall closeComm(int cid);
//void __fastcall readComm(int cid, uchar *n, char *str, short *result);
//void __fastcall sendComm(int cid, uchar *n, char *str, short *result);
//
//void __fastcall createNetClient(int settings, char *server, int *result);
//void __fastcall createNetServer(int settings, int *result);
//void __fastcall sendNet(int settings, char *data, char *remoteIP, int *count, int *result);
//void __fastcall receiveNet(int settings, char *buffer, int *count, char *senderIP,  int *result);
//void __fastcall closeNetConnection(int closeIP, int *result);
//void __fastcall getLocalIP(char *localIP, int *result);

@end
