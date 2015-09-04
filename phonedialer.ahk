; EXAMPLE #1: This is a working script that adds a new menu item to the bottom of the tray icon menu.

#SingleInstance off
IniRead, IpAddress, phonedialerconf.ini, Settings, ip, 172.17.2.133
IniRead, Username, phonedialerconf.ini, Settings, user, admin
IniRead, Password, phonedialerconf.ini, Settings, pass, admin
tempFile:=A_Temp "" A_ScriptName ".api.tmp"
if 0 < 1
{
	#Persistent  ; Keep the script running until the user exits it.
	Menu, Tray, Icon, icons\phone.ico,1,1
	Menu, Tray, Tip, Phone Dialer
	Menu, Tray, NoStandard
	Menu, Tray, add, Call Clipboard, CallClipboard  ; Creates a new menu item.
	Menu, Tray, add, Call Dialog, CallInput  ; Creates a new menu item.
	Menu, Tray, add, Call Directory, TestDirectory  ; Creates a new menu item.
	Menu, Tray, add,,
	Menu, Tray, add, Configure, ConfigHandler  ; Creates a new menu item.
	Menu, Tray, add, Quit, Quit  ; Creates a new menu item.
	Menu, Tray, Default, Call Clipboard
}
else
{
	telLink = tel:
	
	Loop, %0%  ; For each parameter:
	{
		param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
		;MsgBox, 4,, Parameter number %A_Index% is %param%.  Continue?
		IfInString, param, %telLink%
		{
			callNum(param)
			ExitApp
		}
		else
			break
	}
	
	ExitApp
}
return

TestDirectory:
	Gui, Dir: New,, Directory
	Gui, Dir: Add, ListBox,, Test|2|Three
	Gui, Dir: Show

ConfigHandler:
	Gui, Config: New, , Phone Dialer Configuration
	Gui, Config: Add, Text,, IP Address:
	Gui, Config: Add, Text,, Username:
	Gui, Config: Add, Text,, Password:
	Gui, Config: Add, Button, gSaveData Default Y+20, Save
	Gui, Config: Add, Button, gCancel X+m, Cancel
	Gui, Config: Add, Edit, r1 W100 vIpAddress ym, %IpAddress%
	Gui, Config: Add, Edit, r1 W100 vUsername, %Username%
	Gui, Config: Add, Edit, r1 W100 vPassword, %Password%
	Gui, Config: Show
	return

SaveData:
	Gui, Config: Submit
	IniWrite, %IpAddress%, phonedialerconf.ini, Settings, ip
	IniWrite, %Username%, phonedialerconf.ini, Settings, user
	IniWrite, %Password%, phonedialerconf.ini, Settings, pass
	return

Cancel:
	Gui, Config: Cancel
	return

Quit:
	ExitApp
	return

CallClipboard:
	phoneNum := clipboard
	complete := CallNum(phoneNum)
	return
	
CallInput:
	InputBox phoneNum, Number to call:
	CallNum(phoneNum)
	return

CallNum(phoneNum)
{
	;MsgBox, Before: %phoneNum%
	phoneNum := RegExReplace(phoneNum, "[^0-9]", "")
	;Msgbox, After: %phoneNum%
	
	global Username
	global Password
	global IpAddress
	UrlDownloadToFile, http://%Username%:%Password%@%IpAddress%/servlet?number=%phoneNum%&outgoing_uri=0, %tempFile%
	Sleep, 200
	FileDelete, %tempFile%
	return true
}