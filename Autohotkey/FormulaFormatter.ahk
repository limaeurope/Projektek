#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Persistent
	OnClipboardChange("ClipChanged")
return

ClipChanged(Type)
{
	;~ IfWinActive Expression Editor
	;~ {
		sRegexIncTab := "(?:[a-zA-Z]+)\s*\("
		sRegex := "(?:" . sRegexIncTab . "|\)\s*\;?|\;" . ")"

		FoundPos := RegExMatch(Clipboard, sRegex)
		if FoundPos
		{
			sOriginal := Clipboard
			;~ sOriginal := "CONCAT ( "" ) ""; "" 2 "")"
			sResult := ""
			iPrevPos = 1
			iPrevPrevPos := iPrevPos
			iTabs = 0


			while pos := RegExMatch(sOriginal, sRegex, matched, A_Index=1?1: iPrevPos)
			{


				_btwn := SubStr(sOriginal, iPrevPrevPos, pos - iPrevPrevPos)

				RegExReplace(_btwn, """" , "", iFound)

				if Mod(iFound, 2) == 1
				{
					iPrevPrevPos := iPrevPos
					iPrevPos := pos+StrLen(matched)
					continue
				}

				Loop, %iTabs% {
					_msg .= "`t"
				}

				_msg .= RegExReplace(_btwn, "^\s*", "")

				if RegExMatch(matched, "\)", _matched)
				{
					iTabs -= 1
				}

				_msg .= RegExReplace(matched, "^\s*", "")

				_msg .= "`n"

				if RegExMatch(matched, sRegexIncTab, _matched)
				{
					iTabs += 1
				}

				iPrevPos := pos+StrLen(matched)
				iPrevPrevPos := iPrevPos
			}
			_msg .= SubStr(sOriginal, iPrevPos, StrLen(sOriginal) - iPrevPos + 1)
			;MsgBox %_msg%

			OnClipboardChange("ClipChanged", 0)
			Clipboard := _msg
			OnClipboardChange("ClipChanged", 1)
		}
	;~ }
}