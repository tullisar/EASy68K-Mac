*-----------------------------------------------------------
* 68K Tetris
* Created by Martin Wilson
* 2005
* 
*
*-----------------------------------------------------------
	ORG	$800

BLACK		EQU	$00000000
MAROON		EQU	$00000080
GREEN		EQU	$00008000
OLIVE		EQU	$00008080
NAVY		EQU	$00800000
PURPLE		EQU	$00800080
TEAL		EQU	$00808000
GRAY		EQU	$00808080
RED		EQU	$000000FF
LIME		EQU	$0000FF00
YELLOW		EQU	$0000FFFF
BLUE		EQU	$00FF0000
FUCHSIA		EQU	$00FF00FF
AQUA		EQU	$00FFFF00
LTGRAY		EQU	$00C0C0C0
WHITE		EQU	$00FFFFFF


START	ORG	$1000

		bsr		INIT
		bsr		GAMELOOP
		bsr		GAMEEND
		STOP		#$2000

**********************************************************************
* INIT								     *
*  								     *
*  								     *
*  								     *
**********************************************************************

INIT
		move.l		#12,d0			Turn Off Keyboard Echo
		move.l		#0,d1
		trap		#15

		move.l		#17,d1
		move.l		#92,d0
		trap		#15

		move.l		#0,Score
		move.l		#0,Lines

		move.l		#24,BlockSize
		move.l		#10,BoardWidth
		move.l		#20,BoardHeight
		move.l		#200,BoardSize

		move.l		#50,d0
		move.l		d0,TimeToNextMove
		move.l		d0,MoveTime

		move.l		#0,BlockAliveFlag
		
		LEA		BlockColours,a0
		LEA		LineRemoveStack,a6

		move.l		#RED,(a0)+
		move.l		#GREEN,(a0)+
		move.l		#BLUE,(a0)+
		move.l		#PURPLE,(a0)+

		move.l		#0,BlockColSelect
		move.l		#5,BlockSelect

		LEA		BlockLayout,a0
		move.l		a0,NextBlock

		move.l		#13,NextBlockX
		move.l		#10,NextBlockY

		move.l		#0,GameOver

		bsr		INITBLOCKS

		bsr 		NEWBLOCK
		rts

**********************************************************************
* GAME LOOP							     *
*  								     *
*  								     *
*   								     *
**********************************************************************
GAMELOOP	
		
		move.l		#8,d0		Get time since midnight
		trap		#15
		move.l		d1,d2
TIMELOOP
		trap		#15		Limit Framerate.
		sub.l		d2,d1
		cmp		#15,d1
		blt		TIMELOOP

*Count down to next block drop.
		move.l		TimeToNextMove,d0
		sub.l		d1,d0
		move.l		d0,TimeToNextMove
		cmp		#0,d0
		blt		TIMETOUPDATEBLOCK
		jmp		CONTINUELOOP


TIMETOUPDATEBLOCK
		bsr		UPDATEBLOCK

		move.l		GameOver,d0
		cmp		#1,d0
		beq		GAMEISOVER
		jmp		DRAWSETUP

CONTINUELOOP

		move.l		BlockSelect,d0
		add.l		#5,d0
		
		cmp		#7,d0
		blt		NORESETFORBLOCKSELECT
		sub.l		#7,d0

NORESETFORBLOCKSELECT
		move.l		d0,BlockSelect

		bsr		STOREPREVIOUSPOSITION
		bsr		TAKEINPUT
		bsr		PROCESSCOLLISION
		jmp		DRAWSETUP

DRAWSETUP

*Set Text Cursor
		move.l		#11,d0			
		move.l		#33,d1			COl
		lsl.l		#8,d1			
		trap		#15

*Draw Score 
		lea		ScoreDisplay,a1
		move.l		#17,d0
		move.l		Score,d1
		trap		#15

*Set Text Cursor
		move.l		#11,d0			
		move.l		#33,d1			COl
		lsl.l		#8,d1
		add.l		#1,d1			
		trap		#15
*Draw Score 
		lea		LinesDisplay,a1
		move.l		#17,d0
		move.l		Lines,d1
		trap		#15

*Setup for board drawing
		move.l		0,d5			
		move.l		0,d6			Setup Board Array X
		move.l		0,d7			Setup Board Array Y
		LEA		Board,a0		Setup Board Pointer
	
DRAWSTART
*Draw current block and inc board pointer
		move.l		(a0)+,d1
		move.b		#81,d0
		trap		#15		set fill colour

		move.l		BlockSize,d0	Get Block Size

		move.l		d6,d1		Set X1
		muls		d0,d1

		move.l		d1,d3		Set X2
		add.l		d0,d3	
		
		move.l		d7,d2		Set Y1
		muls		d0,d2

		move.l		d2,d4		Set Y2
		add.l		d0,d4

		move.b		#87,d0		Set Circle Draw
		trap		#15	

*Update counters
		add.l		#1,d5
		add.l		#1,d6

*Check that we are at end
		move.l		BoardSize,d0
		cmp		d0,d5
		beq.l		DRAWEND

*Check that we are end of row
		move.l		BoardWidth,d0	
		cmp 		d0,d6
		beq.l		NEXTROW
		jmp		DRAWSTART

NEXTROW	
		move.l 		#0,d6
		add.l		#1,d7
		jmp		DRAWSTART

DRAWEND
		bsr		DRAWCURRENTBLOCK
		bsr		DRAWNEXTBLOCK

		move.l		#94,d0		Flip Back Buffer
		trap		#15

		move.l		#$FF00,d1	Clear Back Buffer
		move.l		#11,d0
		trap		#15
		
		jmp		GAMELOOP

GAMEISOVER
		rts
ENDGAMELOOP
		rts

**********************************************************************
* End Game							     *
* Called when game loop fineshes				     *
*  								     *
*  								     *
**********************************************************************
GAMEEND
		rts

**********************************************************************
* UPDATE BLOCK							     *
* Called to update game logic each game step (not frame)	     *
*  								     *
*  								     *
**********************************************************************
UPDATEBLOCK
		movem.l		d0/d1,-(a7)

		move.l		BlockAliveFlag,d0
		cmp		#1,d0
		beq		BLOCKALIVE
		bsr		REMOVECOMPLETELINES
		bsr		NEWBLOCK
		move.l		#0,d0
		jmp		BLOCKSTILLALIVE
		
BLOCKALIVE
		bsr		STOREPREVIOUSPOSITION
		
		move.l		MoveTime,d0
		move.l		d0,TimeToNextMove
		move.l		BlockY,d1
		add.l		#1,d1
		move.l		d1,BlockY

		bsr		TESTOVERLAP
		cmp		#1,d0
		beq		BLOCKDEAD

		bsr		TESTBOTTOMOUTOFBOUNDS
		cmp		#1,d0
		beq		BLOCKDEAD

		jmp		BLOCKSTILLALIVE

BLOCKDEAD
		move.l		#0,BlockAliveFlag
		bsr		RESTOREPREVIOUSPOSITION
		bsr		ADDBLOCKTOBOARD
		bsr		CHECKFORCOMPLETELINES

		movem.l		(a7)+,d0/d1
		rts

BLOCKSTILLALIVE
		movem.l		(a7)+,d0/d1
		rts
**********************************************************************
* ADDBLOCK							     *
* d0 BlockColour						     *
* d1 X								     *
* d2 Y								     *
**********************************************************************

ADDBLOCK
		movem.l		d0-d4/a1,-(a7)
		lea		Board,a1
		lsl.l		#2,d1
		lsl.l		#2,d2
		move.l		BoardWidth,d4
		muls		d4,d2
		add.l		d1,d2
		add.l		d2,a1
		move.l		d0,(a1)
		movem.l		(a7)+,d0-d4/a1
		rts

**********************************************************************
* GETBLOCK							     *
* d0 BlockColour						     *
* d1 X								     *
* d2 Y								     *
**********************************************************************
GETBLOCK
		movem.l		d1-d4/a1,-(a7)
		lea		Board,a1
		lsl.l		#2,d1
		lsl.l		#2,d2
		
		move.l		BoardWidth,d4
		muls		d4,d2
		
		add.l		d1,d2
		add.l		d2,a1
		move.l		(a1),d0
		movem.l		(a7)+,d1-d4/a1
		rts	


**********************************************************************
* COPY ROW							     *
* Copies one row of blocks to another				     *
* a1 = source, a0 = destination					     *
* 								     *
**********************************************************************
COPYROW
		movem.l		d0-d1/a0/a1,-(a7)
		move.l		#-1,d1
COPYROWLOOP
		add.l		#1,d1
		move.l		(a1)+,d0
		move.l		d0,(a0)+

		cmp		#9,d1
		blt		COPYROWLOOP

		movem.l		(a7)+,d0-d1/a0/a1
		rts

**********************************************************************
* STORE PREVIOUS POSITION					     *
* Stores last frames block data for collision response		     *
* 								     *
* 								     *
**********************************************************************
STOREPREVIOUSPOSITION

		move.l		d0,-(a7)

		move.l		BlockX,d0
		move.l		d0,OldBlockX

		move.l		BlockY,d0
		move.l		d0,OldBlockY

		move.l		CurrentBlockRot,d0
		move.l		d0,OldBlockRot

		move.l		(a7)+,d0
		rts

**********************************************************************
* RESTORE PREVIOUS POSITION					     *
* Restores last frames block data for collision response	     *
* 								     *
* 								     *
**********************************************************************
RESTOREPREVIOUSPOSITION

		move.l		d0,-(a7)

		move.l		OldBlockX,d0
		move.l		d0,BlockX

		move.l		OldBlockY,d0
		move.l		d0,BlockY

		move.l		OldBlockRot,d0
		move.l		d0,CurrentBlockRot

		move.l		(a7)+,d0
		rts

**********************************************************************
* PROCESS COLLISION						     *
* Handles block collision and response, setting game state	     *
* flags for the main game loop					     *
* 								     *
**********************************************************************
PROCESSCOLLISION

		bsr 		TESTOVERLAP
		cmp		#1,d0
		beq		REVERT
		
		bsr		TESTSIDEOUTOFBOUNDS
		cmp		#1,d0
		beq		REVERT

		bsr		TESTBOTTOMOUTOFBOUNDS
		cmp		#1,d0
		beq		REVERT

		rts
REVERT
		bsr		RESTOREPREVIOUSPOSITION
		rts

**********************************************************************
* TEST OVERLAP							     *
* Tests current block against board				     *
* Returns 0 in d0 for no collision, 1 for collision		     *
* 								     *
**********************************************************************
TESTOVERLAP
		movem.l		a0/d1-d3,-(a7)

		move.l		CurrentBlock,a0
		move.l		CurrentBlockRot,d0
		muls		#32,d0
		add.l		d0,a0
		
		move.l		#-1,d3
CMP1LOOP
		add.l		#1,d3
		
		move.l		BlockX,d1
		move.l		BlockY,d2

		add.l		(a0)+,d1
		add.l		(a0)+,d2
		bsr		GETBLOCK

		cmp.l		#BLACK,d0
		bne		COLDETECTED1
		
		cmp		#3,d3
		blt		CMP1LOOP
		
		move.l		#0,d0
		movem.l		(a7)+,a0/d1-d3
		rts
		
COLDETECTED1
		move.l		#1,d0
		movem.l		(a7)+,a0/d1-d3
		rts
		
**********************************************************************
* TEST SIDE OUT OF BOUNDS					     *
* Tests current block against board				     *
* Returns 0 in d0 for no collision, 1 for collision		     *
* 								     *
**********************************************************************
TESTSIDEOUTOFBOUNDS
		movem.l		a0/d1-d3,-(a7)

		move.l		CurrentBlock,a0
		move.l		CurrentBlockRot,d0
		muls		#32,d0
		add.l		d0,a0
		
		move.l		#-1,d3
CMP2LOOP
		add.l		#1,d3
		
		move.l		BlockX,d1
		move.l		BlockY,d2

		add.l		(a0)+,d1
		add.l		(a0)+,d2

		move.l		BoardWidth,d0
		sub.l		#1,d0
		cmp		#0,d1
		blt		COLDETECTED2
		cmp		d0,d1
		bgt		COLDETECTED2
		
		cmp		#3,d3
		blt		CMP2LOOP
		
		move.l		#0,d0
		movem.l		(a7)+,a0/d1-d3
		rts
		
COLDETECTED2
		move.l		#1,d0
		movem.l		(a7)+,a0/d1-d3
		rts
		

**********************************************************************
* TEST BOTTOM OUT OF BOUNDS					     *
* Tests current block against board				     *
* Returns 0 in d0 for no collision, 1 for collision		     *
* 								     *
**********************************************************************
TESTBOTTOMOUTOFBOUNDS
		movem.l		a0/d1-d3,-(a7)

		move.l		CurrentBlock,a0
		move.l		CurrentBlockRot,d0
		muls		#32,d0
		add.l		d0,a0
		
		move.l		#-1,d3
CMP3LOOP
		add.l		#1,d3
		
		move.l		BlockX,d1
		move.l		BlockY,d2

		add.l		(a0)+,d1
		add.l		(a0)+,d2

		move.l		BoardHeight,d0
		sub.l		#1,d0
		cmp		d0,d2
		bgt		COLDETECTED3
		
		cmp		#3,d3
		blt		CMP3LOOP
		
		move.l		#0,d0
		movem.l		(a7)+,a0/d1-d3
		rts
		
COLDETECTED3
		move.l		#1,d0
		movem.l		(a7)+,a0/d1-d3
		rts

**********************************************************************
* TAKE INPUT							     *
* Processes input for the frame					     *
* 								     *
* 								     *
**********************************************************************
TAKEINPUT
		movem.l		d0/d1,-(a7)

		move.l		#7,d0	Put keycode in d1.b
		trap		#15

		cmp.b		#0,d1
		beq		INPUTEND
		
		move.l		#5,d0
		trap		#15

		cmp.b		#'w',d1
		beq		ROTATERIGHT

		cmp.b		#'s',d1
		beq		MOVEDOWN

		cmp.b		#'a',d1
		beq		MOVELEFT

		cmp.b		#'d',d1
		beq		MOVERIGHT

		jmp		INPUTEND

ROTATERIGHT
		move.l		CurrentBlockRot,d0
		add.l		#1,d0
		bsr		RANGE
		move.l		d0,CurrentBlockRot
		jmp		INPUTEND

MOVEDOWN	
		move.l		BlockY,d0
		add.l		#1,d0
		move.l		d0,BlockY
		jmp		INPUTEND

MOVELEFT
		move.l		BlockX,d0
		sub.l		#1,d0
		move.l		d0,BlockX
		jmp		INPUTEND

MOVERIGHT	
		move.l		BlockX,d0
		add.l		#1,d0
		move.l		d0,BlockX
		jmp		INPUTEND

RANGE
		cmp		#3,d0
		bgt		TOOBIG
		cmp		#0,d0
		blt		TOOLOW
		rts
TOOBIG
		sub.l		#4,d0
		rts
TOOLOW		
		add.l		#4,d0
		rts

INPUTEND
		movem.l		(a7)+,d0/d1
		rts

**********************************************************************
* NEW BLOCK							     *
* Kills the old block and creates a new live block.		     *
* 								     *
* 								     *
**********************************************************************
NEWBLOCK
		movem.l		a0/d0,-(a7)

		move.l		NextBlock,d0
		move.l		d0,CurrentBlock

		LEA		BlockLayout,a0
		move.l		BlockSelect,d0
		muls		#128,d0
		add.l		d0,a0
		move.l		a0,NextBlock

		move.l		#1,BlockAliveFlag
		move.l		BlockColSelect,d0
		add.l		#1,d0
		cmp		#4,d0
		beq		RESETCOLSELECT
		
		jmp		SETUPBLOCK
RESETCOLSELECT
		move.l		#0,d0

SETUPBLOCK
		move.l		d0,BlockColSelect
		LEA		BlockColours,a0
		muls		#4,d0
		add.l		d0,a0

		move.l		(a0),d0
		move.l		d0,CurrentBlockCol
		move.l		#4,BlockX
		move.l		#1,BlockY
		move.l		#0,CurrentBlockRot

		bsr		TESTOVERLAP
		move.l		d0,GameOver

		movem.l		(a7)+,a0/d0
		rts

**********************************************************************
* CHECK FOR COMPLETE LINES					     *
* Tests to see if there are any scoring lines			     *
* 								     *
* 								     *
**********************************************************************
CHECKFORCOMPLETELINES
		movem.l		a0/a1/d0-d4,-(a7)

		LEA		Board,a0
		move.l		a0,a1
		move.l		#-1,d0
		move.l		#0,d3
		
LINELOOP
		add.l		#1,d0
		move.l		#-1,d1

COLUMNLOOP
		add.l		#1,d1

		move.l		(a1)+,d2
		cmp.l		#BLACK,d2
		beq		NEXTLINE
		
		cmp		#9,d1
		blt		COLUMNLOOP

		move.l		a0,a1
		move.l		a1,(a6)+
		move.l		#-1,d1
		add.l		#1,d3

HIGHLIGHLOOP	
		add.l		#1,d1
		move.l		#YELLOW,(a1)+
		cmp		#9,d1
		blt		HIGHLIGHLOOP
NEXTLINE	
		add.l		#40,a0
		move.l		a0,a1	
		cmp		#19,d0
		blt		LINELOOP

		move.l		Lines,d4
		add.l		d3,d4
		move.l		d4,Lines
		muls		d3,d3
		muls		#100,d3

		move.l		Score,d4
		add.l		d4,d3
		move.l		d3,Score

		movem.l		(a7)+,a0/a1/d0-d4
		
		rts

**********************************************************************
* REMOVE COMPLETE LINES						     *
* Removes completed lines from the board. Shuffles other lines down. *
* Adds to the score.						     *
* 								     *
**********************************************************************

REMOVECOMPLETELINES
		movem.l		a0-a2/a4/a5,-(a7)

		LEA		LineRemoveStack,a5
		LEA		Board,a4
		cmp.l		a5,a6
		beq		FINISHEDREMOVE		
		move.l		-(a6),a0

		move.l		a0,a1
		suba.l		#40,a1
		cmp.l		a5,a6
		beq		ONLYONELINE

		move.l		-(a6),a2
		jmp		TESTFORFILLED

ONLYONELINE
		move.l		#0,a2

TESTFORFILLED
		cmp.l		a1,a2
		beq		ONFILLED

		cmp.l		a4,a1
		blt		BLANKREST
		bsr		COPYROW
		suba.l		#40,a0
		suba.l		#40,a1

		cmp.l		a0,a4
		beq		FINISHEDREMOVE
		jmp		TESTFORFILLED
			

ONFILLED
		suba.l		#40,a1
		cmp.l		a5,a6
		beq		STACKEMPTY
		move.l		-(a6),a2
		jmp		TESTFORFILLED

STACKEMPTY
		move.l		#0,a2
		jmp		TESTFORFILLED

BLANKREST
		bsr		BLANKROW
		suba.l		#40,a0
		cmp.l		a0,a4
		bgt		FINISHEDREMOVE
		jmp		BLANKREST
		
FINISHEDREMOVE
		movem.l		(a7)+,a0-a2/a4/a5
		rts

**********************************************************************
* BLANK ROW							     *
* Clears the row pointed to by a0				     *
* 								     *
* 								     *
**********************************************************************
BLANKROW
		movem.l		a0/d0,-(a7)
		move.l		#-1,d0
BLANKLOOP
		add.l		#1,d0
		move.l		#BLACK,(a0)+
		cmp		#9,d0
		blt		BLANKLOOP

		movem.l		(a7)+,a0/d0
		rts	
**********************************************************************
* ADD BLOCK TO BOARD						     *
* Adds the current block to the board of dead blocks		     *
* 								     *
* 								     *
**********************************************************************
ADDBLOCKTOBOARD
		movem.l		d0-d4/a0,-(a7)

		move.l		CurrentBlockCol,d0
		move.l		#-1,d4
		move.l		CurrentBlock,a0
		move.l		CurrentBlockRot,d3
		muls		#32,d3
		add.l		d3,a0
ADDBLOCKLOOP
		add.l		#1,d4
		move.l		BlockX,d1
		move.l		BlockY,d2
		
		add.l		(a0)+,d1
		add.l		(a0)+,d2
		
		bsr		ADDBLOCK
		
		cmp		#3,d4
		blt		ADDBLOCKLOOP

		movem.l		(a7)+,d0-d4/a0
		rts
**********************************************************************
* DRAW CURRENT BLOCK						     *
* Draws the current play block to the screen			     *
* 								     *
* 								     *
**********************************************************************

DRAWCURRENTBLOCK
		movem.l		d0-d2/d4-d7/a0,-(a7)

		move.l		BlockAliveFlag,d5
		cmp		#0,d5
		beq		BLOCKDRAWEND

		move.l		0,d5			
		move.l		CurrentBlock,a0		Setup Board Pointer
		move.l		CurrentBlockRot,d0
		muls		#32,d0
		add.l		d0,a0

		
BLOCKDRAWSTART
*Draw current block and inc board pointer
		move.l		CurrentBlockCol,d1
		move.b		#81,d0
		trap		#15		set fill colour

		move.l		BlockSize,d0	Get Block Size
		
		move.l		BlockX,d1	Get Block X
		move.l		BlockY,d2	Get Block Y

		add.l		(a0)+,d1	Set X1
		muls		d0,d1

		move.l		d1,d3		Set X2
		add.l		d0,d3	
		
		add.l		(a0)+,d2	Set Y1
		muls		d0,d2

		move.l		d2,d4		Set Y2
		add.l		d0,d4

		move.b		#87,d0		Set Circle Draw
		trap		#15	

*Check that we are at end
		add.l		#1,d5

		move.l		#4,d0
		cmp		d0,d5
		beq.l		BLOCKDRAWEND
		
		jmp		BLOCKDRAWSTART
BLOCKDRAWEND

		movem.l		(a7)+,d0-d2/d4-d7/a0
		rts

**********************************************************************
* DRAW NEXT BLOCK						     *
* Draws the next play block to the screen			     *
* 								     *
* 								     *
**********************************************************************

DRAWNEXTBLOCK
		movem.l		d0-d2/d4-d7/a0,-(a7)

		move.l		0,d5			
		move.l		NextBlock,a0		Setup Board Pointer
		move.l		0,d0
		muls		#32,d0
		add.l		d0,a0

		
NEXTBLOCKDRAWSTART
*Draw current block and inc board pointer
		move.l		CurrentBlockCol,d1
		move.b		#81,d0
		trap		#15		set fill colour

		move.l		BlockSize,d0	Get Block Size
		
		move.l		NextBlockX,d1	Get Block X
		move.l		NextBlockY,d2	Get Block Y

		add.l		(a0)+,d1	Set X1
		muls		d0,d1

		move.l		d1,d3		Set X2
		add.l		d0,d3	
		
		add.l		(a0)+,d2	Set Y1
		muls		d0,d2

		move.l		d2,d4		Set Y2
		add.l		d0,d4

		move.b		#87,d0		Set Circle Draw
		trap		#15	

*Check that we are at end
		add.l		#1,d5

		move.l		#4,d0
		cmp		d0,d5
		beq.l		NEXTBLOCKDRAWEND
		
		jmp		NEXTBLOCKDRAWSTART
NEXTBLOCKDRAWEND

		movem.l		(a7)+,d0-d2/d4-d7/a0
		rts
**********************************************************************
* INIT BLOCKS							     *
* Sets up the memory storing the different blocks in different	     *
* rotations							     *
* 								     *
**********************************************************************
INITBLOCKS

*Block 1, the T shape block

*Rotation 1
***************************

		LEA		BlockLayout,a0

		bsr		INITBLOCK1
		bsr		INITBLOCK2
		bsr		INITBLOCK3
		bsr		INITBLOCK4
		bsr		INITBLOCK5
		bsr		INITBLOCK6
		bsr		INITBLOCK7
		rts


**********************************************************************
* INIT BLOCK 1							     *
*				 *				     *
* 				***				     *
* 								     *
**********************************************************************
INITBLOCK1

*Rotation 1
***************************
		move.l		#0,(a0)+		X1 - Rotation 1
		move.l		#0,(a0)+		Y1 - Rotation 1

		move.l		#-1,(a0)+		X2 - Rotation 1
		move.l		#0,(a0)+		Y2 - Rotation 1

		move.l		#1,(a0)+		X3 - Rotation 1
		move.l		#0,(a0)+		Y3 - Rotation 1

		move.l		#0,(a0)+		X4 - Rotation 1
		move.l		#-1,(a0)+		Y4 - Rotation 1

*Rotation 2
***************************
		move.l		#0,(a0)+		X1 - Rotation 2
		move.l		#0,(a0)+		Y1 - Rotation 2

		move.l		#1,(a0)+		X2 - Rotation 2
		move.l		#0,(a0)+		Y2 - Rotation 2

		move.l		#0,(a0)+		X3 - Rotation 2
		move.l		#1,(a0)+		Y3 - Rotation 2

		move.l		#0,(a0)+		X4 - Rotation 2
		move.l		#-1,(a0)+		Y4 - Rotation 2

*Rotation 3
***************************		
		move.l		#0,(a0)+		X1 - Rotation 3
		move.l		#0,(a0)+		Y1 - Rotation 3

		move.l		#-1,(a0)+		X2 - Rotation 3
		move.l		#0,(a0)+		Y2 - Rotation 3

		move.l		#1,(a0)+		X3 - Rotation 3
		move.l		#0,(a0)+		Y3 - Rotation 3

		move.l		#0,(a0)+		X4 - Rotation 3
		move.l		#1,(a0)+		Y4 - Rotation 3

*Rotation 4
***************************
		move.l		#0,(a0)+		X1 - Rotation 4
		move.l		#0,(a0)+		Y1 - Rotation 4

		move.l		#-1,(a0)+		X2 - Rotation 4
		move.l		#0,(a0)+		Y2 - Rotation 4

		move.l		#0,(a0)+		X3 - Rotation 4
		move.l		#1,(a0)+		Y3 - Rotation 4

		move.l		#0,(a0)+		X4 - Rotation 4
		move.l		#-1,(a0)+		Y4 - Rotation 4
		rts

**********************************************************************
* INIT BLOCK 2							     *
*				**				     *
* 				**				     *
* 								     *
**********************************************************************
INITBLOCK2

*Rotation 1
***************************
		move.l		#0,(a0)+		X1 - Rotation 1
		move.l		#0,(a0)+		Y1 - Rotation 1

		move.l		#1,(a0)+		X2 - Rotation 1
		move.l		#0,(a0)+		Y2 - Rotation 1

		move.l		#1,(a0)+		X3 - Rotation 1
		move.l		#-1,(a0)+		Y3 - Rotation 1

		move.l		#0,(a0)+		X4 - Rotation 1
		move.l		#-1,(a0)+		Y4 - Rotation 1

*Rotation 2
***************************
		move.l		#0,(a0)+		X1 - Rotation 2
		move.l		#0,(a0)+		Y1 - Rotation 2

		move.l		#1,(a0)+		X2 - Rotation 2
		move.l		#0,(a0)+		Y2 - Rotation 2

		move.l		#1,(a0)+		X3 - Rotation 2
		move.l		#-1,(a0)+		Y3 - Rotation 2

		move.l		#0,(a0)+		X4 - Rotation 2
		move.l		#-1,(a0)+		Y4 - Rotation 2

*Rotation 3
***************************		
		move.l		#0,(a0)+		X1 - Rotation 3
		move.l		#0,(a0)+		Y1 - Rotation 3

		move.l		#1,(a0)+		X2 - Rotation 3
		move.l		#0,(a0)+		Y2 - Rotation 3

		move.l		#1,(a0)+		X3 - Rotation 3
		move.l		#-1,(a0)+		Y3 - Rotation 3

		move.l		#0,(a0)+		X4 - Rotation 3
		move.l		#-1,(a0)+		Y4 - Rotation 3

*Rotation 4
***************************
		move.l		#0,(a0)+		X1 - Rotation 4
		move.l		#0,(a0)+		Y1 - Rotation 4

		move.l		#1,(a0)+		X2 - Rotation 4
		move.l		#0,(a0)+		Y2 - Rotation 4

		move.l		#1,(a0)+		X3 - Rotation 4
		move.l		#-1,(a0)+		Y3 - Rotation 4

		move.l		#0,(a0)+		X4 - Rotation 4
		move.l		#-1,(a0)+		Y4 - Rotation 4
		rts

**********************************************************************
* INIT BLOCK 3							     *
*				 				     *
* 				****				     *
* 								     *
**********************************************************************
INITBLOCK3

*Rotation 1
***************************
		move.l		#0,(a0)+		X1 - Rotation 1
		move.l		#0,(a0)+		Y1 - Rotation 1

		move.l		#-1,(a0)+		X2 - Rotation 1
		move.l		#0,(a0)+		Y2 - Rotation 1

		move.l		#1,(a0)+		X3 - Rotation 1
		move.l		#0,(a0)+		Y3 - Rotation 1

		move.l		#2,(a0)+		X4 - Rotation 1
		move.l		#0,(a0)+		Y4 - Rotation 1

*Rotation 2
***************************
		move.l		#0,(a0)+		X1 - Rotation 2
		move.l		#0,(a0)+		Y1 - Rotation 2

		move.l		#0,(a0)+		X2 - Rotation 2
		move.l		#1,(a0)+		Y2 - Rotation 2

		move.l		#0,(a0)+		X3 - Rotation 2
		move.l		#-1,(a0)+		Y3 - Rotation 2

		move.l		#0,(a0)+		X4 - Rotation 2
		move.l		#-2,(a0)+		Y4 - Rotation 2

*Rotation 3
***************************		
		move.l		#0,(a0)+		X1 - Rotation 3
		move.l		#0,(a0)+		Y1 - Rotation 3

		move.l		#-1,(a0)+		X2 - Rotation 3
		move.l		#0,(a0)+		Y2 - Rotation 3

		move.l		#1,(a0)+		X3 - Rotation 3
		move.l		#0,(a0)+		Y3 - Rotation 3

		move.l		#2,(a0)+		X4 - Rotation 3
		move.l		#0,(a0)+		Y4 - Rotation 3

*Rotation 4
***************************
		move.l		#0,(a0)+		X1 - Rotation 4
		move.l		#0,(a0)+		Y1 - Rotation 4

		move.l		#0,(a0)+		X2 - Rotation 4
		move.l		#1,(a0)+		Y2 - Rotation 4

		move.l		#0,(a0)+		X3 - Rotation 4
		move.l		#-1,(a0)+		Y3 - Rotation 4

		move.l		#0,(a0)+		X4 - Rotation 4
		move.l		#-2,(a0)+		Y4 - Rotation 4
		rts

**********************************************************************
* INIT BLOCK 4							     *
*				*				     *
* 				***				     *
* 								     *
**********************************************************************
INITBLOCK4

*Rotation 1
***************************
		move.l		#0,(a0)+		X1 - Rotation 1
		move.l		#0,(a0)+		Y1 - Rotation 1

		move.l		#-1,(a0)+		X2 - Rotation 1
		move.l		#0,(a0)+		Y2 - Rotation 1

		move.l		#1,(a0)+		X3 - Rotation 1
		move.l		#0,(a0)+		Y3 - Rotation 1

		move.l		#-1,(a0)+		X4 - Rotation 1
		move.l		#-1,(a0)+		Y4 - Rotation 1

*Rotation 2
***************************
		move.l		#0,(a0)+		X1 - Rotation 2
		move.l		#0,(a0)+		Y1 - Rotation 2

		move.l		#0,(a0)+		X2 - Rotation 2
		move.l		#1,(a0)+		Y2 - Rotation 2

		move.l		#0,(a0)+		X3 - Rotation 2
		move.l		#-1,(a0)+		Y3 - Rotation 2

		move.l		#1,(a0)+		X4 - Rotation 2
		move.l		#-1,(a0)+		Y4 - Rotation 2

*Rotation 3
***************************		
		move.l		#0,(a0)+		X1 - Rotation 3
		move.l		#0,(a0)+		Y1 - Rotation 3

		move.l		#-1,(a0)+		X2 - Rotation 3
		move.l		#0,(a0)+		Y2 - Rotation 3

		move.l		#1,(a0)+		X3 - Rotation 3
		move.l		#0,(a0)+		Y3 - Rotation 3

		move.l		#1,(a0)+		X4 - Rotation 3
		move.l		#1,(a0)+		Y4 - Rotation 3

*Rotation 4
***************************
		move.l		#0,(a0)+		X1 - Rotation 4
		move.l		#0,(a0)+		Y1 - Rotation 4

		move.l		#0,(a0)+		X2 - Rotation 4
		move.l		#-1,(a0)+		Y2 - Rotation 4

		move.l		#0,(a0)+		X3 - Rotation 4
		move.l		#1,(a0)+		Y3 - Rotation 4

		move.l		#-1,(a0)+		X4 - Rotation 4
		move.l		#1,(a0)+		Y4 - Rotation 4
		rts

**********************************************************************
* INIT BLOCK 5							     *
*				  *				     *
* 				***				     *
* 								     *
**********************************************************************
INITBLOCK5

*Rotation 1
***************************
		move.l		#0,(a0)+		X1 - Rotation 1
		move.l		#0,(a0)+		Y1 - Rotation 1

		move.l		#-1,(a0)+		X2 - Rotation 1
		move.l		#0,(a0)+		Y2 - Rotation 1

		move.l		#1,(a0)+		X3 - Rotation 1
		move.l		#0,(a0)+		Y3 - Rotation 1

		move.l		#1,(a0)+		X4 - Rotation 1
		move.l		#-1,(a0)+		Y4 - Rotation 1

*Rotation 2
***************************
		move.l		#0,(a0)+		X1 - Rotation 2
		move.l		#0,(a0)+		Y1 - Rotation 2

		move.l		#0,(a0)+		X2 - Rotation 2
		move.l		#1,(a0)+		Y2 - Rotation 2

		move.l		#0,(a0)+		X3 - Rotation 2
		move.l		#-1,(a0)+		Y3 - Rotation 2

		move.l		#1,(a0)+		X4 - Rotation 2
		move.l		#1,(a0)+		Y4 - Rotation 2

*Rotation 3
***************************		
		move.l		#0,(a0)+		X1 - Rotation 3
		move.l		#0,(a0)+		Y1 - Rotation 3

		move.l		#-1,(a0)+		X2 - Rotation 3
		move.l		#0,(a0)+		Y2 - Rotation 3

		move.l		#1,(a0)+		X3 - Rotation 3
		move.l		#0,(a0)+		Y3 - Rotation 3

		move.l		#-1,(a0)+		X4 - Rotation 3
		move.l		#1,(a0)+		Y4 - Rotation 3

*Rotation 4
***************************
		move.l		#0,(a0)+		X1 - Rotation 4
		move.l		#0,(a0)+		Y1 - Rotation 4

		move.l		#0,(a0)+		X2 - Rotation 4
		move.l		#-1,(a0)+		Y2 - Rotation 4

		move.l		#0,(a0)+		X3 - Rotation 4
		move.l		#1,(a0)+		Y3 - Rotation 4

		move.l		#-1,(a0)+		X4 - Rotation 4
		move.l		#-1,(a0)+		Y4 - Rotation 4
		rts

**********************************************************************
* INIT BLOCK 6							     *
*				**				     *
* 				 **				     *
* 								     *
**********************************************************************
INITBLOCK6

*Rotation 1
***************************
		move.l		#0,(a0)+		X1 - Rotation 1
		move.l		#0,(a0)+		Y1 - Rotation 1

		move.l		#1,(a0)+		X2 - Rotation 1
		move.l		#0,(a0)+		Y2 - Rotation 1

		move.l		#0,(a0)+		X3 - Rotation 1
		move.l		#-1,(a0)+		Y3 - Rotation 1

		move.l		#-1,(a0)+		X4 - Rotation 1
		move.l		#-1,(a0)+		Y4 - Rotation 1

*Rotation 2
***************************
		move.l		#0,(a0)+		X1 - Rotation 2
		move.l		#0,(a0)+		Y1 - Rotation 2

		move.l		#1,(a0)+		X2 - Rotation 2
		move.l		#0,(a0)+		Y2 - Rotation 2

		move.l		#0,(a0)+		X3 - Rotation 2
		move.l		#1,(a0)+		Y3 - Rotation 2

		move.l		#1,(a0)+		X4 - Rotation 2
		move.l		#-1,(a0)+		Y4 - Rotation 2

*Rotation 3
***************************		
		move.l		#0,(a0)+		X1 - Rotation 3
		move.l		#0,(a0)+		Y1 - Rotation 3

		move.l		#1,(a0)+		X2 - Rotation 3
		move.l		#0,(a0)+		Y2 - Rotation 3

		move.l		#0,(a0)+		X3 - Rotation 3
		move.l		#-1,(a0)+		Y3 - Rotation 3

		move.l		#-1,(a0)+		X4 - Rotation 3
		move.l		#-1,(a0)+		Y4 - Rotation 3

*Rotation 4
***************************
		move.l		#0,(a0)+		X1 - Rotation 4
		move.l		#0,(a0)+		Y1 - Rotation 4

		move.l		#1,(a0)+		X2 - Rotation 4
		move.l		#0,(a0)+		Y2 - Rotation 4

		move.l		#0,(a0)+		X3 - Rotation 4
		move.l		#1,(a0)+		Y3 - Rotation 4

		move.l		#1,(a0)+		X4 - Rotation 4
		move.l		#-1,(a0)+		Y4 - Rotation 4
		rts

**********************************************************************
* INIT BLOCK 7							     *
*				 **				     *
* 				**				     *
* 								     *
**********************************************************************
INITBLOCK7

*Rotation 1
***************************
		move.l		#0,(a0)+		X1 - Rotation 1
		move.l		#0,(a0)+		Y1 - Rotation 1

		move.l		#-1,(a0)+		X2 - Rotation 1
		move.l		#0,(a0)+		Y2 - Rotation 1

		move.l		#0,(a0)+		X3 - Rotation 1
		move.l		#-1,(a0)+		Y3 - Rotation 1

		move.l		#1,(a0)+		X4 - Rotation 1
		move.l		#-1,(a0)+		Y4 - Rotation 1

*Rotation 2
***************************
		move.l		#0,(a0)+		X1 - Rotation 2
		move.l		#0,(a0)+		Y1 - Rotation 2

		move.l		#1,(a0)+		X2 - Rotation 2
		move.l		#0,(a0)+		Y2 - Rotation 2

		move.l		#0,(a0)+		X3 - Rotation 2
		move.l		#-1,(a0)+		Y3 - Rotation 2

		move.l		#1,(a0)+		X4 - Rotation 2
		move.l		#1,(a0)+		Y4 - Rotation 2

*Rotation 3
***************************		
		move.l		#0,(a0)+		X1 - Rotation 3
		move.l		#0,(a0)+		Y1 - Rotation 3

		move.l		#-1,(a0)+		X2 - Rotation 3
		move.l		#0,(a0)+		Y2 - Rotation 3

		move.l		#0,(a0)+		X3 - Rotation 3
		move.l		#-1,(a0)+		Y3 - Rotation 3

		move.l		#1,(a0)+		X4 - Rotation 3
		move.l		#-1,(a0)+		Y4 - Rotation 3

*Rotation 4
***************************
		move.l		#0,(a0)+		X1 - Rotation 4
		move.l		#0,(a0)+		Y1 - Rotation 4

		move.l		#1,(a0)+		X2 - Rotation 4
		move.l		#0,(a0)+		Y2 - Rotation 4

		move.l		#0,(a0)+		X3 - Rotation 4
		move.l		#-1,(a0)+		Y3 - Rotation 4

		move.l		#1,(a0)+		X4 - Rotation 4
		move.l		#1,(a0)+		Y4 - Rotation 4
		rts

**********************************************************************
* Variables							     *
* 								     *
* 								     *
* 								     *
**********************************************************************
ScoreDisplay	dc.b		'Current Score: ',0		Text for score display
LinesDisplay	dc.b		'Current Lines: ',0		Text for line display

BlockColours	ds.l		4				List of block colours
BlockColSelect	ds.l		1				number of block colour to use

BlockX		ds.l		1				Current X pos of block
BlockY		ds.l		1				Current Y pos of block

NextBlockX	ds.l		1				X pos of next block
NextBlockY	ds.l		1				Y pos of next block

OldBlockX	ds.l		1				Last X pos of block
OldBlockY	ds.l		1				Last y pos of block

CurrentBlock	ds.l		1				pointer to current block makeup data
BlockSelect	ds.l		1				Number of block to use
NextBlock	ds.l		1

CurrentBlockRot	ds.l		1				The current rotation of the block
OldBlockRot	ds.l		1				the last rotation of the block

CurrentBlockCol	ds.l		1				the current block colour

BlockLayout	ds.l		224				Array of block data

BlockSize	ds.l		1				Size of a block
BoardSize	ds.l		1				Number of blocks in board
BoardWidth	ds.l		1				Width of board in blocks
BoardHeight	ds.l		1				Height of board in blocks
Board		ds.l		200				Array to contaion the colour of each block on the board 


TimeToNextMove	ds.l		1				Time till next block update (either move down, fix in place or clear rows)
MoveTime	ds.l		1				Time between updates

BlockAliveFlag	ds.l		1				Is block still alive

LineRemoveStack	ds.l		20				Pointer to the stack of filled lines

GameOver	ds.l		1				Stores whether game is over or not

Score		ds.l		1				Stores the score
Lines		ds.l		1				Stores the number of lines
		END	START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
