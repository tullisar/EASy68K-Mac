//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

//---------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "aboutS.h"
#include "def.h"
#include "SIM68Ku.h"


//---------------------------------------------------------------------
#pragma resource "*.dfm"
TAboutFrm *AboutFrm;
//--------------------------------------------------------------------- 
__fastcall TAboutFrm::TAboutFrm(TComponent* AOwner)
	: TForm(AOwner)
{
}
//---------------------------------------------------------------------

void __fastcall TAboutFrm::FormShow(TObject *Sender)
{
  Title->Caption = TITLE;        
}
//---------------------------------------------------------------------------


void __fastcall TAboutFrm::FormKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
   if (Key == VK_F1)
     Form1->displayHelp("CHUCK");
}
//---------------------------------------------------------------------------

