#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Persistent
	OnClipboardChange("ClipChanged")
return

ClipChanged(Type)
{
	IfWinActive Expression Editor
	{
		FoundPos := RegExMatch(Clipboard, "(?:IFS|AND|OR)\s*\(.*\)")
		if FoundPos
		{
			sOriginal := Clipboard
			sResult := ""
			iPrevPos = 1
			iTabs = 0
			sRegexIncTab := "(?:[a-zA-Z]+)\s*\("
			sRegex := "(?:" . sRegexIncTab . "|\)\s*\;?|\;" . ")"

			while pos := RegExMatch(sOriginal, sRegex, matched, A_Index=1?1: iPrevPos)
			{
				Loop, %iTabs% {
					_msg .= "`t"
				}

				_msg .= RegExReplace(SubStr(sOriginal, iPrevPos, pos - iPrevPos), "^\s*", "")

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
			}
			_msg .= SubStr(sOriginal, iPrevPos, StrLen(sOriginal) - iPrevPos + 1)
			;MsgBox %_msg%

			OnClipboardChange("ClipChanged", 0)
			Clipboard := _msg
			OnClipboardChange("ClipChanged", 1)
		}
	}
}