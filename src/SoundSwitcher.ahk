#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Include, inc/VA.ahk
#SingleInstance force
#Persistent
APP_NAME = SoundToggle
VERSION = 0.1
DEVICES := []
TOTALDEVICES := readConfig("TOTALDEVICES", 10)

Menu, Tray, NoStandard
Menu, Tray, Icon, C:\Windows\System32\mmsys.cpl, 1
Menu, Tray, Add, %APP_NAME% v%VERSION%, Reload
Menu, Tray, Add
; Add Devices To Tray
getDevices()
Menu, Tray, Add
Menu, Tray, Add, Sound Preferences, OpenAudioSettings
Menu, Tray, Add
Menu, Tray, Add, Exit, Exit

; Get Current Device
CurrentDevice := VA_GetDeviceName(VA_GetDevice())
CurrentDeviceID := VA_GetDevice(CurrentDevice)

; Check the current default device
Menu, Tray, Check, %CurrentDevice%
Menu, Tray, Tip, %CurrentDevice%
return

getDevices(){
    global
    Loop %TOTALDEVICES% ;total number of my mixer devices
    {
    	try {
    		VA_dev:= VA_GetDevice(A_Index)
        	VA_dev_name:= VA_GetDeviceName(VA_dev)
    	} catch e {
    		break
    	}
        writeConfig("TOTALDEVICES", A_Index)
        if(HasVal(DEVICES, VA_dev_name)){ ; If DEVICES array already has this value, skip
            ; Do Nothing
        }
        else { ; Otherwise add it to the list of devices
            DEVICES.push(VA_dev_name)
			Menu, Tray, Add, %VA_dev_name%, ToggleMonitor
        }
    }
	DEVICES_DDL := 
	For Index, Value In DEVICES
		DEVICES_DDL .= Value . "|"
}

ToggleMonitor:
	MenuItem := A_ThisMenuItem
	VA_SetDefaultEndpoint(MenuItem, 0)
	reload
return

Exit:
ExitApp
return

Reload:
Reload
return

OpenAudioSettings:
Run, mmsys.cpl
return

; Read and Write to Registry
readConfig(name, default=""){
	global
	RegRead, RegKeyValue, HKEY_CURRENT_USER\Software\%APP_NAME%, %name%
	if(RegKeyValue == ""){
		writeConfig(name, default)
		return default
	}
	return RegKeyValue
}

writeConfig(name, value){
	global
	RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\%APP_NAME%, %name%, %value%
	return
}

removeConfig(name){
	global
	RegDelete, HKEY_CURRENT_USER\Software\%APP_NAME%, %name%
}

; Basic function to check array for a value
HasVal(haystack, needle) {
	if !(IsObject(haystack)) || (haystack.Length() = 0)
		return 0
	for index, value in haystack
		if (value = needle)
			return index
	return 0
}
