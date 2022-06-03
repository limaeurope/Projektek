#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetTitleMatchMode, 2

nTabs = 1		;nTabs
nSpaces = 4		;a Tab is nSpaces spaces
nDigs = 3		;nDigs digits after decimal
nCols = 0
sStatus = 0		;0 = unchanged

; https://jacks-autohotkey-blog.com/2020/06/08/autohotkey-tooltip-command-tricks/
OnMessage(0x200,"CheckControl") ; WM_MOUSEMOVE = 0x200

return 
 
CheckControl()
{
  MouseGetPos,,,, VarControl
  IfEqual, VarControl, Edit1
    Message := "Number of digits"
  Else IfEqual, VarControl, Edit2
    Message := " Number of tabs"
  Else IfEqual, VarControl, Edit3
    Message := "Status code string"
  ToolTip % Message
}

TabulatorGUI()
{
	global nTabs, sStatus, inText, nDigs, nSpaces

	;tDialog := 'T' . nSpaces * 4
	
	Gui, 1: New
	Gui, 1: font, s10, Courier New
	Gui, 1: Add, Edit,        w45 h20   x5  y0 vnDigs	gDigsRecalculate,	%nDigs%
	Gui, 1: Add, Edit,        w45 h20  x55  y0 vnTabs	gTabsRecalculate, 	%nTabs%
	Gui, 1: Add, Edit,        w45 h20 x105  y0 vsStatus	gStatusRecalculate, %sStatus%
	
	Gui, 1: Add, Edit,       w590 r10   x5 y25 T16 WantTab vinText,			%inText%
	      
	Gui, 1: Add, Button, default, OK
	Gui, 1: Show, x300 y200 h200 w600, Tabulator
	gosub, Reformat
	return
	
	ButtonOK:
	GuiClose:
		Gui, Destroy
	return
	
	StatusRecalculate:
		GuiControlGet, sStatus
		gosub Reformat
	return
	
	TabsRecalculate:
		GuiControlGet, nTabs
		gosub Reformat
	return
	
	DigsRecalculate:
		GuiControlGet, nDigs
		gosub Reformat
	return
	
	Reformat:
		_inText := ""
		sArray := []
		maxLeadDigs := []
		maxTrailDigs := []

		sLeadingChars := "^[^.]*\.?"
		
		Loop, Parse, Clipboard, `n
		{
			_iRows := A_Index
			
;			if nCols > 0
;			{
;				Loop, nCols
;				{
;					maxLeadDigs%A_Index%	= 0
;					maxTrailDigs%A_Index%	= 0
;				}
;			}

			Loop, Parse, A_LoopField, `,
			{
				if (A_LoopField ~= "\S+") > 0	;not empty
				{
					_nTrailDigs := StrLen(RegExReplace(RegExReplace(Round(A_LoopField, nDigs), "0*\Z"), sLeadingChars))
					_nTrailDigs := _nTrailDigs < nDigs ? _nTrailDigs : nDigs
					sArray[_iRows][A_Index] := Round(RegExReplace(A_LoopField, "^\s*"), _nTrailDigs)
					msgBox % _nTrailDigs
					msgBox % sArray[_iRows][A_Index]

					_nLeadDigs := RegExMatch(sArray[_iRows][A_Index], "\.|\Z") - 1
					maxLeadDigs[A_Index] := maxLeadDigs[A_Index] > _nLeadDigs ? maxLeadDigs[A_Index] : _nLeadDigs
					
					_trailDigs := StrLen(RegExReplace(sArray[_iRows][A_Index], sLeadingChars)) + (RegExMatch(sArray[_iRows][A_Index], "\.") > 0 ? 1 : 0) + 1
					maxTrailDigs[A_Index] := maxTrailDigs[A_Index] > _trailDigs ? maxTrailDigs[A_Index] : _trailDigs
					
					nCols := nCols > A_Index ? nCols : A_Index
				}
			}
		}
		
		Loop, %nCols%
		{
			maxTrailDigs[A_Index] :=  ceil(maxTrailDigs[A_Index] / nTabs) * nTabs
		}
		
		Loop, %_iRows%
		{
			_iRow := A_Index
			
			Loop %nCols%
			{
				nIntDigs := RegExMatch(sArray[_iRow][A_Index], "\.|\Z") - 1
;				msgBox % sArray[_iRow][A_Index]
;				msgBox % nIntDigs
				_nSpaces := nTabs * nSpaces - nIntDigs

				Loop, % _nSpaces // nSpaces 
					_inText .= "`t"
				Loop, % mod(_nSpaces , nSpaces) 
					_inText .= " " 

				if (A_Index < nCols)
				{
					trailSpaces := maxTrailDigs[A_Index] - StrLen(RegExReplace(sArray[_iRow][A_Index], sLeadingChars))
					Loop, % (trailSpaces + nSpaces - 1) // nSpaces
						_inText .= "`t"
				} 
				else
				{
					if (sStatus <> "0" and sStatus <> "")
					{
						if sArray[_iRow][A_Index] <> -1
						{
							if (sStatus ~= "\d+" > 0)
							{

								if (sArray[_iRow][A_Index] ~= "9\d{2}" > 0)
								{
									sArray[_iRow][A_Index] := 900 + sStatus
								}
								else if (sArray[_iRow][A_Index] ~= "4\d{3}" > 0)
								{
									sArray[_iRow][A_Index] := 4000 + sStatus
								}
								else
								{
									sArray[_iRow][A_Index] := sStatus
								}
							}
							else
							{
								if (sArray[_iRow][A_Index] ~= "9\d{2}" > 0)
								{
									sArray[_iRow][A_Index] := "900 + " . sStatus
								}
								else if (sArray[_iRow][A_Index] ~= "4\d{3}" > 0)
								{
									sArray[_iRow][A_Index] := "4000 + " . sStatus
								}
								else 
								{
									sArray[_iRow][A_Index] := sStatus
								}
							}
						}
					}
				}
				_inText .= RegExReplace(sArray[_iRow][A_Index], "^\s*") . ","
			}
			if _iRow < nRows
			{			
				_inText .= "`n"
			}
		}
		GuiControl,, inText, %_inText%
	return
}

OnClipboardChange:
IfWinActive, ARCHICAD
{
	inText = 
	Loop, Parse, Clipboard, `n
	{
		FoundPos := RegExMatch(A_LoopField, "(?:\s*\-?[0-9.E]+\,){2,4}")
		if FoundPos 
		{
			inText .= A_LoopField . "`n"
		}
		else
		{
			break
			;FIXME
		}
	}
	
	if inText
	{
		TabulatorGUI()
	}
}

