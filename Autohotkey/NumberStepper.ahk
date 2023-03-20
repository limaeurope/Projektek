SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

iNum = 0
sStorey = 00.

#Persistent
	OnClipboardChange("ClipChanged", 1)
	+#v:: incNum()
	+#x:: decNum()
	+#c:: setNum()
return


incNum()
{
	global iNum, sStorey
	iNum := iNum + 1
	sClip := sStorey . Format("{:02d}", iNum)
	OnClipboardChange("ClipChanged", 0)
	Clipboard:=sClip
	OnClipboardChange("ClipChanged", 1)
	Menu, Tray, Tip, %sClip%
	Send, ^v
}

decNum()
{
	global iNum, sStorey
	iNum := iNum - 1
	sClip := sStorey . Format("{:02d}", iNum)
	OnClipboardChange("ClipChanged", 0)
	Clipboard:=sClip
	OnClipboardChange("ClipChanged", 1)
	Menu, Tray, Tip, %sClip%
	Send, ^v
}

setNum()
{
	global iNum, sStorey

	Gui, 1: New
	Gui, 1: font, s10, Courier New
	Gui, 1: Add, Edit,        w145 h20  x5  	y0 vsStorey	gsetINum, 			%sStorey%
	Gui, 1: Add, Edit,        w45 h20   x155  	y0 viNum	gsetINum,			%iNum%
	Gui, 1: Add, Button, default, OK
	Gui, 1: Show, x300 y200 h100 w205, Tabulator
	return

	setINum:
		GuiControlGet, iNum
		GuiControlGet, sStorey
		OnClipboardChange("ClipChanged", 0)
		Clipboard:=sStorey . Format("{:02d}", iNum)
		OnClipboardChange("ClipChanged", 1)
		Menu, Tray, Tip, %sClip%
	return

	ButtonOK:
	GuiClose:
		Gui, Destroy
	return
}

ClipChanged(Type)
{
	global sStorey
		sStorey := Clipboard
}