#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetTitleMatchMode, 2

nTabs = 1		; nTabs, input, how many tabs should be between/before commas if everything else is empty
nSpaces = 4		; a Tab is nSpaces spaces
nDigs = 3		; nDigs digits after decimal; for rounding
nCols = 0
sStatus = 0		;0 = unchanged

; https://jacks-autohotkey-blog.com/2020/06/08/autohotkey-tooltip-command-tricks/
OnMessage(0x200,"CheckControl") ; WM_MOUSEMOVE = 0x200

return

CheckControl()
{
  MouseGetPos,,,, VarControl
  IfEqual, VarControl, Edit1
    Message := "Number of digits after decimal point"
  Else IfEqual, VarControl, Edit2
    Message := " Number of tabs between commad"
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
		nRows := 0
		iDecimalPositions := []

		sLeadingChars := "^[^.]*\.?"

		Loop, Parse, Clipboard, `n
		{
			_iRows := A_Index
			sArray[_iRows] := []
			nRows += 1

			Loop, Parse, A_LoopField, `,
			{
				if (A_LoopField ~= "\S+") > 0	;not empty
				{
					_nTrailDigs := StrLen(RegExReplace(RegExReplace(Round(A_LoopField, nDigs), "0*\Z"), sLeadingChars))
					_nTrailDigs := _nTrailDigs < nDigs ? _nTrailDigs : nDigs

					sArray[_iRows][A_Index] := Round(RegExReplace(A_LoopField, "^\s*"), _nTrailDigs)

					_nLeadDigs := RegExMatch(sArray[_iRows][A_Index], "\.|\Z") - 1
					maxLeadDigs[A_Index] := maxLeadDigs[A_Index] > _nLeadDigs ? maxLeadDigs[A_Index] : _nLeadDigs

					_trailDigs := StrLen(RegExReplace(sArray[_iRows][A_Index], sLeadingChars)) + (RegExMatch(sArray[_iRows][A_Index], "\.") > 0 ? 1 : 0) + 1
					maxTrailDigs[A_Index] := maxTrailDigs[A_Index] > _trailDigs ? maxTrailDigs[A_Index] : _trailDigs

					nCols := nCols > A_Index ? nCols : A_Index
				}
			}
		}

		_iPrevDecPos = 0
		_iPrevTrailDigs = 0
		Loop, %nCols%
		{
			maxTrailDigs[A_Index] :=  ceil(maxTrailDigs[A_Index] / nTabs) * nTabs
			_nSpacesToAdd := _iPrevTrailDigs + maxLeadDigs[A_Index]
			_nSpacesToAdd := _nSpacesToAdd > nTabs * nSpaces ? _nSpacesToAdd : nTabs * nSpaces
			_iDecPos := _iPrevDecPos + _nSpacesToAdd
			iDecimalPositions[A_Index] := ceil(_iDecPos / nSpaces) * nSpaces
			_iPrevDecPos := iDecimalPositions[A_Index]
			_iPrevTrailDigs := maxTrailDigs[A_Index]
		}

		Loop, %_iRows%
		{
			_iRow := A_Index
			_iPrevPos := 0

			Loop %nCols%
			{
				nIntDigs := RegExMatch(sArray[_iRow][A_Index], "\.|\Z") - 1
;				_nSpaces := nTabs * nSpaces - nIntDigs
;				_nSpaces := iDecimalPositions[A_Index] - _iPrevPos - nIntDigs
				_nTabs := (iDecimalPositions[A_Index] - nIntDigs) // nSpaces - _iPrevPos // nSpaces
				_iTabPos := (_iPrevPos // nSpaces + _nTabs) * nSpaces
				_nSpaces := iDecimalPositions[A_Index] - nIntDigs - (_iTabPos > _iPrevPos ? _iTabPos : _iPrevPos)
				_iTrailDigits := StrLen(RegExReplace(sArray[_iRow][A_Index], sLeadingChars))
				_iPrevPos := iDecimalPositions[A_Index] + _iTrailDigits + 1	+ 1 ; 1 for point, 1 for comma

;				Loop, % _nSpaces // nSpaces
				Loop, % _nTabs
					_inText .= "`t"
;				Loop, % mod(_nSpaces , nSpaces)
				Loop, % _nSpaces
					_inText .= " "

				if (A_Index < nCols)
				{
					;~ trailSpaces := maxTrailDigs[A_Index] - StrLen(RegExReplace(sArray[_iRow][A_Index], sLeadingChars))
					;~ Loop, % (trailSpaces + nSpaces - 1) // nSpaces
						;~ _inText .= "`t"
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
IfWinActive, Notepad++
;IfWinActive, ARCHICAD
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
