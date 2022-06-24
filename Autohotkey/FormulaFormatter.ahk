#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;~ #Persistent
;~ OnClipboardChange("ClipChanged")
;~ return


;~ ClipChanged(Type)
;~ {
	;~ #IfWinActive Notepad++
	;~ {
		;~ FoundPos := RegExMatch(Clipboard, "(?:IFS|AND|OR)\s*\(.*\)")
		;~ if FoundPos
		;~ {
			;~ sOriginal := Clipboard
			sOriginal := "IFS (AND ( ))"
			sResult := ""
			iPrevPos = 1
			iTabs = 0

			while pos := RegExMatch(sOriginal, "(?:IFS|AND|OR)\s*\(", matched, A_Index=1?1: iPrevPos)
			{
				_msg .= matched
				_msg .= "`n"
				_msg .= SubStr(sOriginal, iPrevPos, pos)

				iPrevPos := pos+StrLen(matched)
			}

			Clipboard := _msg
		;~ }
	;~ }
;~ }