#Region INCLUDES
#include "ButtonConstants.au3"
#include "GUIConstantsEx.au3"
#include "GUIListBox.au3"
#include "StaticConstants.au3"
#include "WindowsConstants.au3"
#include "Misc.au3"
#include "FontConstants.au3"
#include "ColorConstants.au3"
#include "Array.au3"
#include "SliderConstants.au3"
#include "File.au3"
#include "TrayConstants.au3"
#include "ScrollBarConstants.au3"
#include "ScrollBarsConstants.au3"
#include "MsgBoxConstants.au3"
#include "Clipboard.au3"
#include "GDIPlus.au3"
#include "ScreenCapture.au3"
#include "WinAPI.au3"
#EndRegion INCLUDES

If FileExists(@ScriptDir & BinaryToString("0x5C6D656469615C75695C646972636865636B2E726573")) = False Then
	MsgBox(16, "File location error", "Program or source code was likely moved out of the main directory" _
			 & @CRLF & @CRLF & "This error can be fixed by moving files back into the correct TabulatioN directory" _
			 & @CRLF & @CRLF & "Please use the desktop shortcut instead")
	Exit
EndIf

#Region OPTIONS
Global $version = "1.0.1"
TraySetIcon(@ScriptDir & "\media\ico\icon.ico")
Opt("TrayMenuMode", 3) ;hide default paused and exit
Opt("TrayAutoPause", 0)
#EndRegion OPTIONS

#Region GLOBALS
Global $Positive, $Negative, $item_normal, $item_rare, $item_epic, $iniMute, $iniVolume, $GUI_OPTIONS
Global $enemy_1_defeated, $enemy_2_defeated, $enemy_3_defeated, $enemy_4_defeated, $enemy_5_defeated, $enemy_6_defeated, $currentEnemy
Global $sCappuccino, $sStickStone, $sDeepBreath, $sAnkh, $sEnergyDrink, $sVoodoo, $sZenGarden, $sGreenMushroom
Global $sCrack, $sSinisterCurse, $sNirvana, $sRainbowStar, $sAttack, $sGameOver, $sEnemyLoad1, $sEnemyLoad2
Global $sEnemyLoad3, $sEnemyLoad4, $sEnemyLoad5, $sBossLoad, $sYouWin, $sPositiveClick, $sNegativeClick, $butInv1, $sec
Global $sAnkh = @ScriptDir & "\media\wav\ankh.wav"
Global $sCappuccino = @ScriptDir & "\media\wav\cappuccino.wav"
Global $sCrack = @ScriptDir & "\media\wav\crack.wav"
Global $sDeepBreath = @ScriptDir & "\media\wav\deepbreath.wav"
Global $sEnergyDrink = @ScriptDir & "\media\wav\energydrink.wav"
Global $sGreenMushroom = @ScriptDir & "\media\wav\greenmushroom.wav"
Global $sNirvana = @ScriptDir & "\media\wav\nirvana.wav"
Global $sRainbowStar = @ScriptDir & "\media\wav\rainbowstar.wav"
Global $sSinisterCurse = @ScriptDir & "\media\wav\sinistercurse.wav"
Global $sStickStone = @ScriptDir & "\media\wav\stickstone.wav"
Global $sVoodoo = @ScriptDir & "\media\wav\voodoo.wav"
Global $sZenGarden = @ScriptDir & "\media\wav\zengarden.wav"
Global $sItemNormal = @ScriptDir & "\media\wav\itemnormal.wav"
Global $sItemRare = @ScriptDir & "\media\wav\itemrare.wav"
Global $sItemEpic = @ScriptDir & "\media\wav\itemepic.wav"
Global $sPositiveClick = @ScriptDir & "\media\wav\positiveclick.wav"
Global $sNegativeClick = @ScriptDir & "\media\wav\negativeclick.wav"
Global $sAttack = @ScriptDir & "\media\wav\attack.wav"
Global $sEnemyLoad1 = @ScriptDir & "\media\wav\enemyload1.wav"
Global $sEnemyLoad2 = @ScriptDir & "\media\wav\enemyload2.wav"
Global $sEnemyLoad3 = @ScriptDir & "\media\wav\enemyload3.wav"
Global $sEnemyLoad4 = @ScriptDir & "\media\wav\enemyload4.wav"
Global $sEnemyLoad5 = @ScriptDir & "\media\wav\enemyload5.wav"
Global $sBossLoad = @ScriptDir & "\media\wav\bossload.wav"
Global $sGameOver = @ScriptDir & "\media\wav\gameover.wav"
Global $sYouWin = @ScriptDir & "\media\wav\youwin.wav"
Global $sClick = @ScriptDir & "\media\wav\click.wav"
Global $dCappuccino = "Add 20 to your current damage"
Global $dStickStone = "Remove 20 hp from enemy"
Global $dDeepBreath = "Turn time increased by 1 second each turn for the rest of this game"
Global $dAnkh = "Reset damage back to 100"
Global $dEnergyDrink = "Add 50 to your current damage"
Global $dVoodooDoll = "Remove 50 hp from enemy"
Global $dZenGarden = "Turn time increased by 2 seconds each turn for the rest of this game"
Global $dGreenMushroom = "Add 2 turns"
Global $dCrack = "Add 100 to your current damage"
Global $dSinisterCurse = "Remove 100 hp from enemy"
Global $dNirvana = "Turn time increased by 3 seconds each turn for the rest of this game"
Global $dRainbowStar = "Add 1 special additional positive turn"
Global $nameEnemy1 = "Boodtholomew"
Global $nameEnemy2 = "Pacific Pirate"
Global $nameEnemy3 = "Candorless"
Global $nameEnemy4 = "Lazarus"
Global $nameEnemy5 = "Serafina"
Global $nameEnemy6 = "Pu Stickles"
Global $inv_x = 398
Global $inv_y = 301
Global $rainbow = False
Global $rb_arr[8] = ["0xff4d4d", "0xffc24d", "0xfffd4d", "0x55ff4d", "0x4dfff0", "0x4d83ff", "0x904dff", "0xff65eb"]
Global $originaltime = 7
Global $time = 7
Global $score = 0
#EndRegion GLOBALS

#Region PRE-GUI IINITIALIZATION
If FileExists(@ScriptDir & "\settings.ini") = False Then ;Checks if settings.ini exists. If not, creates it and opens the program once it exists.
	ProgressOn("TabulatioN", "Creating Settings file....", "0%")
	create_ini()
	For $i = 10 To 100 Step 10
		Sleep(200)
		ProgressSet($i, $i & "%")
	Next
	ProgressSet(100, "Done", "Complete")
	Do
		Sleep(100)
	Until FileExists(@ScriptDir & "\settings.ini") = True
	ProgressOff()
Else
	Sleep(10)
EndIf
If _Singleton(@ScriptName, 1) = 0 Then Exit MsgBox(262144 + 16, "Error!", @ScriptName & " is already running!") ;redundancy check
ini_read()
PopArrays()
#EndRegion PRE-GUI IINITIALIZATION

#Region SHORTCUT
If FileExists(@DesktopDir & "\TabulatioN.lnk") = False Or IniRead(@ScriptDir & "\settings.ini", "settings", "played", "") = "no" Then
	IniWrite(@ScriptDir & "\settings.ini", "settings", "played", "yes")
	$parentDir = StringLeft(@scriptDir,StringInStr(@scriptDir,"\",0,-1)-1)
	If FileExists($parentDir & "\Run Game.bat") Then
		FileCreateShortcut($parentDir & "\Run Game.bat", @DesktopDir & "\TabulatioN.lnk", "", "", "", @ScriptDir & "\media\ico\icon.ico")
		MsgBox(0,"Welcome!", "Welcome to TabulatioN!" & @CRLF & @CRLF & "A game shortcut has been placed on your desktop." & @CRLF & @CRLF & "You won't see this message again. Have fun!")
	Else
		MsgBox(16,"Error 9","File error. Please re-download TabulatioN.")
		Exit 9
	EndIf
EndIf
#EndRegion SHORTCUT

#Region TRAY
$trayDonate = TrayCreateItem("Donate")
$trayAbout = TrayCreateItem("About")
TrayCreateItem("")
$trayExit = TrayCreateItem("Exit")
TraySetState($TRAY_ICONSTATE_SHOW)
#EndRegion TRAY
;left, top, width, height
#Region GUI_MAIN
$GUI_MAIN = GUICreate("TabulatioN", 603, 465, -1, -1)
$uiPic = GUICtrlCreatePic(@ScriptDir & "\media\UI\ui2.res", 0, 0, 603, 465) ;MAIN GUI BACKGROUND
GUICtrlSetState(-1, $GUI_DISABLE)
$picEnemy1 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\enemy1.res", 38, 52, 42, 42)
GUICtrlSetTip(-1, $nameEnemy1 & @CRLF & "Fond of the Irish exit.")
GUICtrlSetState(-1, $GUI_HIDE)
$picEnemy2 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\enemy2.res", 38, 52, 42, 42)
GUICtrlSetTip(-1, $nameEnemy2 & @CRLF & "Noble cartographer.")
GUICtrlSetState(-1, $GUI_HIDE)
$picEnemy3 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\enemy3.res", 38, 52, 42, 42)
GUICtrlSetTip(-1, $nameEnemy3 & @CRLF & "Scholarly spellcaster.")
GUICtrlSetState(-1, $GUI_HIDE)
$picEnemy4 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\enemy4.res", 38, 52, 42, 42)
GUICtrlSetTip(-1, $nameEnemy4 & @CRLF & "Wildlife tycoon.")
GUICtrlSetState(-1, $GUI_HIDE)
$picEnemy5 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\enemy5.res", 38, 52, 42, 42)
GUICtrlSetTip(-1, $nameEnemy5 & @CRLF & "As sweet as the day is long.")
GUICtrlSetState(-1, $GUI_HIDE)
$picEnemy6 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\boss.res", 38, 52, 42, 42)
GUICtrlSetTip(-1, $nameEnemy6 & @CRLF & "Walking existential crisis.")
GUICtrlSetState(-1, $GUI_HIDE)
$labCurrent = GUICtrlCreateLabel("", 210, 36, 180, 70, $SS_CENTER)
GUICtrlSetFont(-1, 50, 750, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$labEnemyHP = GUICtrlCreateLabel("", 85, 51, 65, 35, $SS_RIGHT)
GUICtrlSetFont(-1, 25, 700, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$labTurns = GUICtrlCreateLabel("", 239, 274, 50, 30, $SS_CENTER)
GUICtrlSetFont(-1, 20, 600, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$labTimer_Plus = GUICtrlCreateLabel("+", 353, 262, 45, 45, $SS_CENTER)
GUICtrlSetFont(-1, 35, 800, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetColor(-1, "0x00ff06")
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetState($labTimer_Plus, $GUI_HIDE)
$labOverkill = GUICtrlCreateLabel("OVERKILL!", 39, 56, 200, 50, $SS_LEFT)
GUICtrlSetFont(-1, 20, 800, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, $COLOR_RED)
GUICtrlSetState($labOverkill, $GUI_HIDE)
$labTimer = GUICtrlCreateLabel(StringFormat("%.1f", $time), 314, 278, 48, 25, $SS_CENTER) ;timer
GUICtrlSetFont(-1, 17, 600, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetState($labTimer, $GUI_HIDE)
$labScore = GUICtrlCreateLabel($score, 435, 51, 90, 40, $SS_CENTER)
GUICtrlSetFont(-1, 25, 750, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetState($labScore, $GUI_HIDE)
$Button1 = GUICtrlCreateButton("", 24, 136, 169, 129)
GUICtrlSetFont(-1, 30, 600, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetState(-1, $GUI_DISABLE)
$Button2 = GUICtrlCreateButton("", 216, 136, 169, 129)
GUICtrlSetFont(-1, 30, 600, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetState(-1, $GUI_DISABLE)
$Button3 = GUICtrlCreateButton("", 408, 136, 169, 129)
GUICtrlSetFont(-1, 30, 600, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetState(-1, $GUI_DISABLE)
$listMoves = GUICtrlCreateList("", 24, 307, 180, 140, BitOR($WS_BORDER, $WS_VSCROLL, $WS_HSCROLL), 0) ;BitOR style disables alphanumerical sorting
GUICtrlSetFont(-1, 11.5, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$butNewGame = GUICtrlCreatePic(@ScriptDir & "\media\UI\butNewGame.res", 220, 324, 161, 39)
$butNewGameDown = GUICtrlCreatePic(@ScriptDir & "\media\UI\butNewGameDown.res", 220, 324, 161, 39)
GUICtrlSetState(-1, $GUI_HIDE)
$butOptions = GUICtrlCreatePic(@ScriptDir & "\media\UI\butOptions.res", 220, 366, 161, 37)
$butOptionsDown = GUICtrlCreatePic(@ScriptDir & "\media\UI\butOptionsDown.res", 220, 366, 161, 37)
GUICtrlSetState(-1, $GUI_HIDE)
$butExit = GUICtrlCreatePic(@ScriptDir & "\media\UI\butExit.res", 220, 406, 161, 39)
$butExitDown = GUICtrlCreatePic(@ScriptDir & "\media\UI\butExitDown.res", 220, 406, 161, 39)
GUICtrlSetState(-1, $GUI_HIDE)
$butInv1 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\cappuccino.res", $inv_x, $inv_y, 42, 42)
GUICtrlSetTip(-1, "Cappuccino" & @CRLF & "Adds 20 to your current damage")
GUICtrlSetState(-1, $GUI_HIDE)
$butInv2 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\stickandstone.res", $inv_x + 45, $inv_y, 42, 42)
GUICtrlSetTip(-1, "Stick and Stone" & @CRLF & "Removes 20 HP from enemy")
GUICtrlSetState(-1, $GUI_HIDE)
$butInv3 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\breath.res", $inv_x + 90, $inv_y, 42, 42)
GUICtrlSetTip(-1, "Deep Breath" & @CRLF & "Turn time increased by 1 second each turn for the rest of this game")
GUICtrlSetState(-1, $GUI_HIDE)
$butInv4 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\ankh.res", $inv_x + 135, $inv_y, 42, 42)
GUICtrlSetTip(-1, "Ankh" & @CRLF & "Sets current damage to 100")
GUICtrlSetState(-1, $GUI_HIDE)
$butInv5 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\energydrink.res", $inv_x, $inv_y + 50, 42, 42)
GUICtrlSetTip(-1, "Energy Drink" & @CRLF & "Adds 50 to your current damage")
GUICtrlSetState(-1, $GUI_HIDE)
$butInv6 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\voodoodoll.res", $inv_x + 45, $inv_y + 50, 42, 42)
GUICtrlSetTip(-1, "Voodoo Doll" & @CRLF & "Removes 50 HP from enemy")
GUICtrlSetState(-1, $GUI_HIDE)
$butInv7 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\zengarden.res", $inv_x + 90, $inv_y + 50, 42, 42)
GUICtrlSetTip(-1, "Zen Garden" & @CRLF & "Turn time increased by 2 seconds each turn for the rest of this game")
GUICtrlSetState(-1, $GUI_HIDE)
$butInv8 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\greenmushroom.res", $inv_x + 135, $inv_y + 50, 42, 42)
GUICtrlSetTip(-1, "Green Mushroom" & @CRLF & "Adds 2 turns")
GUICtrlSetState(-1, $GUI_HIDE)
$butInv9 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\crack.res", $inv_x, $inv_y + 99, 42, 42)
GUICtrlSetTip(-1, "Crack" & @CRLF & "Adds 100 to your current damage")
GUICtrlSetState(-1, $GUI_HIDE)
$butInv10 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\sinistercurse.res", $inv_x + 45, $inv_y + 99, 42, 42)
GUICtrlSetTip(-1, "Sinister Curse" & @CRLF & "Removes 100 HP from enemy")
GUICtrlSetState(-1, $GUI_HIDE)
$butInv11 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\nirvana.res", $inv_x + 90, $inv_y + 99, 42, 42)
GUICtrlSetTip(-1, "Nirvana" & @CRLF & "Turn time increased by 3 seconds each turn for the rest of this game")
GUICtrlSetState(-1, $GUI_HIDE)
$butInv12 = GUICtrlCreatePic(@ScriptDir & "\media\bmp\rainbowstar.res", $inv_x + 135, $inv_y + 99, 42, 42)
GUICtrlSetTip(-1, "Rainbow Star" & @CRLF & "Adds 1 special additional positive turn")
GUICtrlSetState(-1, $GUI_HIDE)
GUISetState(@SW_SHOW)
#EndRegion GUI_MAIN
;left, top, width, height

#Region GUI_SCORE
$GUI_SCORE = GUICreate("Victory", 201, 152, -1, -1)
$uiPic2 = GUICtrlCreatePic(@ScriptDir & "\media\UI\scorescreen.res", 0, 0, 201, 152) ;GUI BACKGROUND
GUICtrlSetState(-1, $GUI_DISABLE)
$butScoreShare = GUICtrlCreatePic(@ScriptDir & "\media\UI\butScoreShare.res", 13, 88, 81, 31)
$butScoreShareDown = GUICtrlCreatePic(@ScriptDir & "\media\UI\butScoreShareDown.res", 13, 88, 81, 31)
GUICtrlSetState(-1, $GUI_HIDE)
$butScoreNew = GUICtrlCreatePic(@ScriptDir & "\media\UI\butScoreNewGame.res", 108, 88, 81, 31)
$butScoreNewdOWN = GUICtrlCreatePic(@ScriptDir & "\media\UI\butScoreNewGameDown.res", 108, 88, 81, 31)
GUICtrlSetState(-1, $GUI_HIDE)
$labFinalScore = GUICtrlCreateLabel("0", 105, 44, 90, 30)
GUICtrlSetFont(-1, 22, 800, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUISetState(@SW_HIDE)
#EndRegion GUI_SCORE
;left, top, width, height
#Region GUI_OPTIONS
$GUI_OPTIONS = GUICreate("Options", 220, 188, -1, -1)
$ui_Options = GUICtrlCreatePic(@ScriptDir & "\media\UI\options_ui.res", 0, 0, 220, 188) ;GUI BACKGROUND
GUICtrlSetState(-1, $GUI_DISABLE)
$checkMute = GUICtrlCreateCheckbox("", 58, 34, 13, 13)
If $iniMute = 1 Then GUICtrlSetState($checkMute, $GUI_CHECKED)
If $iniMute = 4 Then GUICtrlSetState($checkMute, $GUI_UNCHECKED)
$Slider1 = GUICtrlCreateSlider(35, 92, 150, 25, BitOR($TBS_TOOLTIPS, $TBS_AUTOTICKS, $TBS_ENABLESELRANGE))
GUICtrlSetBkColor(-1, "0xa0977d")
GUICtrlSetLimit(-1, 100, 0) ; control, max, min
GUICtrlSetData($Slider1, $iniVolume)
$butOptionsOkay = GUICtrlCreatePic(@ScriptDir & "\media\UI\butOptionsOkay.res", 48, 135, 119, 39)
$butOptionsOkayDown = GUICtrlCreatePic(@ScriptDir & "\media\UI\butOptionsOkayDown.res", 48, 135, 119, 39)
GUICtrlSetState(-1, $GUI_HIDE)
GUISetState(@SW_HIDE)
#EndRegion GUI_OPTIONS

#Region GUI_TIME
$GUI_TIME = GUICreate("Game Over", 195, 146, -1, -1)
$ui_Options = GUICtrlCreatePic(@ScriptDir & "\media\UI\time_ui.res", 0, 0, 195, 146) ;GUI BACKGROUND
GUICtrlSetState(-1, $GUI_DISABLE)
$butTimeRetry = GUICtrlCreatePic(@ScriptDir & "\media\UI\butTimeRetry.res", 15, 95, 80, 39)
$butTimeRetryDown = GUICtrlCreatePic(@ScriptDir & "\media\UI\butTimeRetryDown.res", 15, 95, 80, 39)
GUICtrlSetState(-1, $GUI_HIDE)
$butTimeCancel = GUICtrlCreatePic(@ScriptDir & "\media\UI\butTimeCancel.res", 100, 95, 80, 39)
$butTimeCancelDown = GUICtrlCreatePic(@ScriptDir & "\media\UI\butTimeCancelDown.res", 100, 95, 80, 39)
GUICtrlSetState(-1, $GUI_HIDE)
GUISetState(@SW_HIDE)
#EndRegion GUI_TIME

#Region GUI ENEMYDEFEATED
$GUI_ENEMYDEFEATED = GUICreate("Enemy Defeated", 275, 210, -1, -1)
$ui_enemyDefeated = GUICtrlCreatePic(@ScriptDir & "\media\UI\enemyDefeated.res", 0, 0, 275, 210) ;GUI BACKGROUND
GUICtrlSetState(-1, $GUI_DISABLE)
$picLoot = GUICtrlCreatePic(@ScriptDir & "\media\UI\dircheck.res", 50, 90, 42, 42)
$nameLoot = GUICtrlCreateLabel("???", 100, 75, 140, 20, $SS_CENTER)
GUICtrlSetFont(-1, 12, 800, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetColor(-1, "0xfbedc2")
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$descLoot = GUICtrlCreateLabel("???", 95, 95, 145, 53, $SS_CENTER)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "Century Gothic", $CLEARTYPE_QUALITY)
GUICtrlSetColor(-1, "0xfbedc2")
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
$butNextEncounter = GUICtrlCreatePic(@ScriptDir & "\media\UI\butNextEncounter.res", 46, 156, 184, 46)
$butNextEncounterDown = GUICtrlCreatePic(@ScriptDir & "\media\UI\butNextEncounterDown.res", 46, 156, 184, 46)
GUICtrlSetState(-1, $GUI_HIDE)
GUISetState(@SW_HIDE)
#EndRegion GUI ENEMYDEFEATED

#Region YOU_DIED
$YOU_DIED = GUICreate("Game Over", 195, 146, -1, -1)
$ui_YouDied = GUICtrlCreatePic(@ScriptDir & "\media\UI\youdied.res", 0, 0, 195, 146) ;GUI BACKGROUND
GUICtrlSetState(-1, $GUI_DISABLE)
$butYDRetry = GUICtrlCreatePic(@ScriptDir & "\media\UI\butTimeRetry.res", 15, 95, 80, 39)
$butYDRetryDown = GUICtrlCreatePic(@ScriptDir & "\media\UI\butTimeRetryDown.res", 15, 95, 80, 39)
GUICtrlSetState(-1, $GUI_HIDE)
$butYDCancel = GUICtrlCreatePic(@ScriptDir & "\media\UI\butTimeCancel.res", 100, 95, 80, 39)
$butYDCancelDown = GUICtrlCreatePic(@ScriptDir & "\media\UI\butTimeCancelDown.res", 100, 95, 80, 39)
GUICtrlSetState(-1, $GUI_HIDE)
GUISetState(@SW_HIDE)
#EndRegion YOU_DIED

#Region POST GUI
GUISetIcon(@ScriptDir & "\media\ico\icon.ico", "", $GUI_MAIN)
GUISetIcon(@ScriptDir & "\media\ico\icon.ico", "", $GUI_SCORE)
GUISetIcon(@ScriptDir & "\media\ico\settings.ico", "", $GUI_OPTIONS)
GUISetIcon(@ScriptDir & "\media\ico\icon_loot.ico", "", $GUI_ENEMYDEFEATED)
GUISetIcon(@ScriptDir & "\media\ico\icon_dead.ico", "", $YOU_DIED)
GUISetIcon(@ScriptDir & "\media\ico\icon_time.ico", "", $GUI_TIME)
SetVol()
ApplyStyle()
#EndRegion POST GUI

#Region MAIN LOOP
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $butInv1
			BuffAnimate()
			UseItem("Cappuccino")
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sCappuccino)
		Case $butInv2
			DebuffAnimate()
			UseItem("Stick and Stone")
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sStickStone)
		Case $butInv3
			TimeAnimate()
			UseItem("Deep Breath")
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sDeepBreath)
		Case $butInv4
			AnkhAnimate()
			UseItem("Ankh")
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sAnkh)
		Case $butInv5
			BuffAnimate()
			UseItem("Energy Drink")
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sEnergyDrink)
		Case $butInv6
			DebuffAnimate()
			UseItem("Voodoo Doll")
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sVoodoo)
		Case $butInv7
			TimeAnimate()
			UseItem("Zen Garden")
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sZenGarden)
		Case $butInv8
			MushroomAnimate()
			UseItem("Green Mushroom")
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sGreenMushroom)
		Case $butInv9
			BuffAnimate()
			UseItem("Crack")
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sCrack)
		Case $butInv10
			DebuffAnimate()
			UseItem("Sinister Curse")
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sSinisterCurse)
		Case $butInv11
			TimeAnimate()
			UseItem("Nirvana")
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sNirvana)
		Case $butInv12
			UseItem("Rainbow Star")
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sRainbowStar)
		Case $butNewGame
			ButClick("NewGame")
			ResetGame()
			NewGame()
			GUICtrlSetState($labScore, $GUI_SHOW)
			GUICtrlSetData($listMoves, "")
			GUICtrlSetData($listMoves, $nameEnemy1 & " start!")
		Case $Button1
			ResetTimer()
			Global $val = GUICtrlRead($Button1)
			$logval = GUICtrlRead($labCurrent)
			Sound_PosNeg()
			Logic()
			GUICtrlSendMsg($listMoves, $WM_VSCROLL, $SB_LINEDOWN, 0) ;scrolls listbox down
		Case $Button2
			ResetTimer()
			Global $val = GUICtrlRead($Button2)
			$logval = GUICtrlRead($labCurrent)
			Sound_PosNeg()
			Logic()
			GUICtrlSendMsg($listMoves, $WM_VSCROLL, $SB_LINEDOWN, 0) ;scrolls listbox down
		Case $Button3
			ResetTimer()
			Global $val = GUICtrlRead($Button3)
			$logval = GUICtrlRead($labCurrent)
			Sound_PosNeg()
			Logic()
			GUICtrlSendMsg($listMoves, $WM_VSCROLL, $SB_LINEDOWN, 0) ;scrolls listbox down
		Case $butOptions
			ButClick("Options")
			RelativePosition()
			GUISetState(@SW_SHOW, $GUI_OPTIONS)
		Case $checkMute
			ini_write()
		Case $Slider1
			ini_write()
			SetVol()
		Case $butOptionsOkay
			ButClick("OptionsOkay")
			GUISetState(@SW_HIDE, $GUI_OPTIONS)
			ini_write()
			SetVol()
		Case $butScoreShare
			ButClick("ScoreShare")
			Share()
		Case $butScoreNew
			ButClick("ScoreNew")
			GUISetState(@SW_HIDE, $GUI_SCORE)
			Retry()
		Case $butTimeRetry
			ButClick("TimeRetry")
			GUISetState(@SW_HIDE, $GUI_TIME)
			Retry()
		Case $butYDRetry
			ButClick("YDRetry")
			GUISetState(@SW_HIDE, $YOU_DIED)
			Retry()
		Case $butTimeCancel
			ButClick("TimeCancel")
			GUISetState(@SW_HIDE, $GUI_TIME)
			Cancel()
		Case $butYDCancel
			ButClick("YDCancel")
			GUISetState(@SW_HIDE, $YOU_DIED)
			Cancel()
		Case $butNextEncounter
			ButClick("NextEncounter")
			GUISetState(@SW_HIDE, $GUI_ENEMYDEFEATED)
			NewGame()
		Case $GUI_EVENT_CLOSE
			If WinActive("Options") Then
				GUISetState(@SW_HIDE, $GUI_OPTIONS)
				ini_write()
				SetVol()
			ElseIf WinActive("Victory") Then
				EnableButtons()
				PostVictory()
				GUISetState(@SW_HIDE, $GUI_SCORE)
				ToolTip("")
			ElseIf WinActive("Game Over") Then
				Cancel()
				GUISetState(@SW_HIDE, $GUI_TIME)
				GUISetState(@SW_HIDE, $YOU_DIED)
			ElseIf WinActive("Enemy Defeated") Then
				GUISetState(@SW_HIDE, $GUI_ENEMYDEFEATED)
				NewGame()
			ElseIf WinActive("TabulatioN") Then
				Exit 342
			EndIf
		Case $butExit
			Exit 350
	EndSwitch
	Switch TrayGetMsg()
		Case $trayDonate
			Donate()
		Case $trayAbout
			About()
		Case $trayExit
			Exit 359
	EndSwitch
WEnd
#EndRegion MAIN LOOP

#Region MAIN FUNCTIONS
Func NewGame()
	DisableButtons()
	If $enemy_1_defeated = False Then
		LoadEnemy(1)
	ElseIf $enemy_2_defeated = False Then
		LoadEnemy(2)
	ElseIf $enemy_3_defeated = False Then
		LoadEnemy(3)
	ElseIf $enemy_4_defeated = False Then
		LoadEnemy(4)
	ElseIf $enemy_5_defeated = False Then
		LoadEnemy(5)
	ElseIf $enemy_6_defeated = False Then
		LoadEnemy(6)
	Else
		sleep(100)
	EndIf
	GUICtrlSetData($labCurrent, 100)
	GUICtrlSetData($labTurns, 5)
	GUICtrlSetData($labScore, $score)
	GUICtrlSetState($labTimer, $GUI_SHOW)
	Positive()
	StartTimer()
	EnableButtons()
	ApplyStyle()
	ToolTip("")
EndFunc   ;==>NewGame

Func ResetGame()
	AdlibUnRegister("Countdown")
	PopArrays()
	GUICtrlSetData($listMoves, "")
	GUICtrlSetData($labCurrent, "")
	GUICtrlSetData($labTurns, "")
	GUICtrlSetData($labEnemyHP, "")
	GUICtrlSetData($Button1, "")
	GUICtrlSetData($Button2, "")
	GUICtrlSetData($Button3, "")
	For $i = 1 To 12
		GUICtrlSetState(Eval("butInv" & $i), $GUI_HIDE)
	Next
	For $e = 1 To 6
		GUICtrlSetState(Eval("picEnemy" & $e), $GUI_HIDE)
	Next
	$Positive = False
	$Negative = False
	Global $time = 7
	Global $rainbow = False
	ApplyStyle()
	ResetScore()
EndFunc   ;==>ResetGame

Func Retry()
	ResetGame()
	NewGame()
	GUICtrlSetState($labScore, $GUI_SHOW)
	GUICtrlSetData($listMoves, "")
	GUICtrlSetData($listMoves, $nameEnemy1 & " start!")
EndFunc   ;==>Retry

Func Cancel()
	EnableButtons()
	GUICtrlSetState($labScore, $GUI_HIDE)
	GUICtrlSetState($labTimer, $GUI_HIDE)
	GUICtrlSetState($Button1, $GUI_DISABLE)
	GUICtrlSetState($Button2, $GUI_DISABLE)
	GUICtrlSetState($Button3, $GUI_DISABLE)
	ResetGame()
EndFunc   ;==>Cancel

Func Positive()
	$Positive = True
	$pos_1 = "+" & Random(1, 20, 1) & Random(1, 9, 1) ; + random number between 11 and 209
	$pos_2 = "x" & Random(1, 2, 1) & "." & Random(0, 9, 1) ; x random number between 1.0 and 2.9
	$pos_3 = Random(100, 300, 1) & "%" ; random % between 100-300
	Local $arr[3] = [$pos_1, $pos_2, $pos_3]
	_ArrayShuffle($arr)
	For $i = 1 To 3
		GUICtrlSetData(Eval("Button" & $i), $arr[$i - 1])
		GUICtrlSetColor(Eval("Button" & $i), "0x057300")
	Next
EndFunc   ;==>Positive

Func Negative()
	$Negative = True
	$neg_1 = "-" & Random(1, 20, 1) & Random(1, 9, 1) ; - random number between 11 and 209
	$neg_2 = "/" & Random(1, 2, 1) & "." & Random(0, 9, 1) ; / random number between 1.0 and 2.9
	$neg_3 = Random(10, 90, 1) & "%" ; random % between 10-90
	Local $arr[3] = [$neg_1, $neg_2, $neg_3]
	_ArrayShuffle($arr)
	For $i = 1 To 3
		GUICtrlSetData(Eval("Button" & $i), $arr[$i - 1])
		GUICtrlSetColor(Eval("Button" & $i), "0x870000")
	Next
EndFunc   ;==>Negative

Func Rainbow() ;round added by Rainbow Star, buffed numbers
	$Positive = True
	$pos_1 = "+" & Random(10, 50, 1) & Random(1, 9, 1) ; + random number between 101 and 509
	$pos_2 = "x" & Random(1, 3, 1) & "." & Random(5, 9, 1) ; x random number between 1.5 and 3.9
	$pos_3 = Random(150, 375, 1) & "%" ; random % between 150-375
	Local $arr[3] = [$pos_1, $pos_2, $pos_3]
	_ArrayShuffle($arr)
	_ArrayShuffle($rb_arr)
	GUICtrlSetData($Button1, $arr[0])
	GUICtrlSetData($Button2, $arr[1])
	GUICtrlSetData($Button3, $arr[2])
	GUICtrlSetColor($Button1, "0x057300")
	GUICtrlSetColor($Button2, "0x057300")
	GUICtrlSetColor($Button3, "0x057300")
	GUICtrlSetBkColor($Button1, $rb_arr[0])
	GUICtrlSetBkColor($Button2, $rb_arr[1])
	GUICtrlSetBkColor($Button3, $rb_arr[2])
	AdlibRegister("RainbowAnimate", 100)
EndFunc   ;==>Rainbow

Func Logic()
	If StringInStr($val, "+", 0, 1, 1, 9) <> 0 Then ;checks if string includes + sign
		$math = StringMid($val, 2) ;removes first character of string to isolate integer
		GUICtrlSetData($labCurrent, Int(GUICtrlRead($labCurrent) + $math))
	ElseIf StringInStr($val, "x", 0, 1, 1, 9) <> 0 Then
		$math = StringMid($val, 2)
		GUICtrlSetData($labCurrent, Int(GUICtrlRead($labCurrent) * $math))
	ElseIf StringInStr($val, "%", 0, 1, 1, 9) <> 0 Then
		$math = StringTrimRight($val, 1)
		If $math >= 100 Then
			$percent = StringLeft($math, 1) & "." & StringRight($math, 2)
			$percentMath = GUICtrlRead($labCurrent) * $percent
			GUICtrlSetData($labCurrent, Int($percentMath))
		Else
			$percent = "0" & "." & $math
			$percentMath = GUICtrlRead($labCurrent) * $percent
			GUICtrlSetData($labCurrent, Int($percentMath))
		EndIf
	ElseIf StringInStr($val, "-", 0, 1, 1, 9) <> 0 Then
		$math = StringMid($val, 2)
		GUICtrlSetData($labCurrent, GUICtrlRead($labCurrent) - $math)
	ElseIf StringInStr($val, "/", 0, 1, 1, 9) <> 0 Then
		$math = StringMid($val, 2)
		$divmath = GUICtrlRead($labCurrent) / $math
		GUICtrlSetData($labCurrent, Int($divmath))
	EndIf
	$turns = GUICtrlRead($labTurns) - 1 ;decrements turn count
	GUICtrlSetData($labTurns, $turns)
	GUICtrlSetData($listMoves, $logval & "   " & $val & "  =  " & GUICtrlRead($labCurrent))
	If GUICtrlRead($labTurns) = 1 And $rainbow = True Then
		Rainbow()
	ElseIf $Positive = True And GUICtrlRead($labTurns) <> 0 Then
		$Positive = False
		Negative()
	ElseIf $Negative = True And GUICtrlRead($labTurns) <> 0 Then
		$Negative = False
		Positive()
	ElseIf GUICtrlRead($labTurns) = 0 Then
		AdlibUnRegister("Countdown")
		DisableButtons()
		$Negative = False
		$Positive = False
		For $i = 1 To 3
			GUICtrlSetData(Eval("Button" & $i), "!!!")
			GUICtrlSetColor(Eval("Button" & $i), 0xffa200)
		Next
		Attack()
	Else
	sleep(100)
		Exit
	EndIf
EndFunc   ;==>Logic

Func Attack()
	ApplyStyle()
	DisableButtons()
	GUICtrlSendMsg($listMoves, $WM_VSCROLL, $SB_LINEDOWN, 0)
	If GUICtrlRead($checkMute) = 4 Then SoundPlay($sAttack)
	Sleep(750)
	If Int(GUICtrlRead($labEnemyHP)) > Int(GUICtrlRead($labCurrent)) Then ;lose round
		If GUICtrlRead($checkMute) = 4 Then SoundPlay($sGameOver)
		DisableButtons()
		RelativePosition()
		GUISetState(@SW_SHOW, $YOU_DIED)
		GUICtrlSetData($listMoves, "You were defeated.")
	ElseIf Int(GUICtrlRead($labEnemyHP)) <= Int(GUICtrlRead($labCurrent)) Then ;win round
		$scoreDiff = Int(GUICtrlRead($labCurrent)) - Int(GUICtrlRead($labEnemyHP))
		$score += $scoreDiff
		GUICtrlSetData($labScore, $score)
		If $currentEnemy = 1 Then
			Global $enemy_1_defeated = True
			GUICtrlSetData($listMoves, $nameEnemy1 & " defeated.")
		ElseIf $currentEnemy = 2 Then
			Global $enemy_2_defeated = True
			GUICtrlSetData($listMoves, $nameEnemy2 & " defeated.")
		ElseIf $currentEnemy = 3 Then
			Global $enemy_3_defeated = True
			GUICtrlSetData($listMoves, $nameEnemy3 & " defeated.")
		ElseIf $currentEnemy = 4 Then
			Global $enemy_4_defeated = True
			GUICtrlSetData($listMoves, $nameEnemy4 & " defeated.")
		ElseIf $currentEnemy = 5 Then
			Global $enemy_5_defeated = True
			GUICtrlSetData($listMoves, $nameEnemy5 & " defeated.")
		ElseIf $currentEnemy = 6 Then
			Global $enemy_6_defeated = True
			GUICtrlSetData($listMoves, $nameEnemy6 & " defeated.")
		EndIf
		If GUICtrlRead($labCurrent) <> "666" Then
			RollForRarity()
		Else
			GiveItem($item_epic, "1")
		EndIf
	EndIf

	If Int(GUICtrlRead($labCurrent)) > Int(GUICtrlRead($labEnemyHP)) * 2 Then
		OverkillAnimate()
	EndIf
	GUICtrlSendMsg($listMoves, $WM_VSCROLL, $SB_LINEDOWN, 0)
	ApplyStyle()
	$rainbow = False
EndFunc   ;==>Attack

Func Victory()
	AdlibUnRegister("Countdown")
	If GUICtrlRead($checkMute) = 4 Then SoundPlay($sYouWin)
	GUICtrlSetData($labFinalScore, $score)
	RelativePosition()
	GUISetState(@SW_SHOW, $GUI_SCORE)
	AdlibUnRegister("Countdown")
	DisableButtons()
EndFunc   ;==>Victory

Func LoadEnemy($e)
	If $e = 1 Then
		GUICtrlSetData($labEnemyHP, 250)
		GUICtrlSetState($picEnemy1, $GUI_SHOW)
		If GUICtrlRead($checkMute) = 4 Then SoundPlay($sEnemyLoad1)
	ElseIf $e = 2 Then
		GUICtrlSetState($picEnemy1, $GUI_HIDE)
		GUICtrlSetData($labEnemyHP, 300)
		GUICtrlSetState($picEnemy2, $GUI_SHOW)
		If GUICtrlRead($checkMute) = 4 Then SoundPlay($sEnemyLoad2)
		GUICtrlSetData($listMoves, $nameEnemy2 & " start!")
		GUICtrlSendMsg($listMoves, $WM_VSCROLL, $SB_LINEDOWN, 0)
	ElseIf $e = 3 Then
		GUICtrlSetState($picEnemy2, $GUI_HIDE)
		GUICtrlSetData($labEnemyHP, 400)
		GUICtrlSetState($picEnemy3, $GUI_SHOW)
		If GUICtrlRead($checkMute) = 4 Then SoundPlay($sEnemyLoad3)
		GUICtrlSetData($listMoves, $nameEnemy3 & " start!")
		GUICtrlSendMsg($listMoves, $WM_VSCROLL, $SB_LINEDOWN, 0)
	ElseIf $e = 4 Then
		GUICtrlSetState($picEnemy3, $GUI_HIDE)
		GUICtrlSetData($labEnemyHP, 500)
		GUICtrlSetState($picEnemy4, $GUI_SHOW)
		If GUICtrlRead($checkMute) = 4 Then SoundPlay($sEnemyLoad4)
		GUICtrlSetData($listMoves, $nameEnemy4 & " start!")
		GUICtrlSendMsg($listMoves, $WM_VSCROLL, $SB_LINEDOWN, 0)
	ElseIf $e = 5 Then
		GUICtrlSetState($picEnemy4, $GUI_HIDE)
		GUICtrlSetData($labEnemyHP, 750)
		GUICtrlSetState($picEnemy5, $GUI_SHOW)
		If GUICtrlRead($checkMute) = 4 Then SoundPlay($sEnemyLoad5)
		GUICtrlSetData($listMoves, $nameEnemy5 & " start!")
		GUICtrlSendMsg($listMoves, $WM_VSCROLL, $SB_LINEDOWN, 0)
	ElseIf $e = 6 Then
		GUICtrlSetState($picEnemy5, $GUI_HIDE)
		GUICtrlSetData($labEnemyHP, 1000)
		GUICtrlSetState($picEnemy6, $GUI_SHOW)
		If GUICtrlRead($checkMute) = 4 Then SoundPlay($sBossLoad)
		GUICtrlSetData($listMoves, $nameEnemy6 & " start!")
		GUICtrlSendMsg($listMoves, $WM_VSCROLL, $SB_LINEDOWN, 0)
	EndIf
	Global $currentEnemy = $e
	EnableButtons()
EndFunc   ;==>LoadEnemy

Func PopArrays()
	Dim $item_normal[4] = ["Cappuccino", "Stick and Stone", "Deep Breath", "Ankh"]
	Dim $item_rare[4] = ["Energy Drink", "Voodoo Doll", "Zen Garden", "Green Mushroom"]
	Dim $item_epic[4] = ["Crack", "Sinister Curse", "Nirvana", "Rainbow Star"]
	Global $enemy_1_defeated = False
	Global $enemy_2_defeated = False
	Global $enemy_3_defeated = False
	Global $enemy_4_defeated = False
	Global $enemy_5_defeated = False
	Global $enemy_6_defeated = False
EndFunc   ;==>PopArrays

Func Sound_PosNeg()
	If $Positive = True Then
		If GUICtrlRead($checkMute) = 4 Then SoundPlay($sPositiveClick)
	Else
		If GUICtrlRead($checkMute) = 4 Then SoundPlay($sNegativeClick)
	EndIf
EndFunc   ;==>Sound_PosNeg

Func DisableButtons()
	For $n = 1 To 3
		GUICtrlSetState(Eval("Button" & $n), $GUI_DISABLE)
	Next
	For $i = 1 To 12
		GUICtrlSetState(Eval("butInv" & $i), $GUI_DISABLE)
	Next
	GUICtrlSetState($butNewGame, $GUI_DISABLE)
	GUICtrlSetState($butOptions, $GUI_DISABLE)
EndFunc   ;==>DisableButtons

Func EnableButtons()
	For $n = 1 To 3
		GUICtrlSetState(Eval("Button" & $n), $GUI_ENABLE)
	Next
	For $i = 1 To 12
		GUICtrlSetState(Eval("butInv" & $i), $GUI_ENABLE)
	Next
	GUICtrlSetState($butNewGame, $GUI_ENABLE)
	GUICtrlSetState($butOptions, $GUI_ENABLE)
EndFunc   ;==>EnableButtons

Func PostVictory()
	For $n = 1 To 3
		GUICtrlSetState(Eval("Button" & $n), $GUI_DISABLE)
	Next
	For $i = 1 To 12
		GUICtrlSetState(Eval("butInv" & $i), $GUI_DISABLE)
	Next
EndFunc   ;==>PostVictory

Func ResetScore()
	$score = 0
	GUICtrlSetData($labScore, $score)
EndFunc   ;==>ResetScore

Func SetVol()
	SoundSetWaveVolume(GUICtrlRead($Slider1))
EndFunc   ;==>SetVol

Func RelativePosition() ;forces new gui window to open centered relative to position of parent window
	Global $hWnd = WinGetHandle("TabulatioN")
	Global $pos = WinGetPos($hWnd)
	If WinActive($GUI_MAIN) = True Then
		WinMove($GUI_OPTIONS, "", $pos[0] + 190, $pos[1] + 80)
		WinMove($GUI_SCORE, "", $pos[0] + 210, $pos[1] + 155)
		WinMove($GUI_TIME, "", $pos[0] + 200, $pos[1] + 155)
		WinMove($YOU_DIED, "", $pos[0] + 200, $pos[1] + 155)
		WinMove($GUI_ENEMYDEFEATED, "", $pos[0] + 160, $pos[1] + 150)
	EndIf
EndFunc   ;==>RelativePosition

Func Share()
	$err = False
	$hWnd = WinGetHandle("Victory")
	$hHBITMAP = _ScreenCapture_CaptureWnd("", $hWnd, 1, 26, 201, 177, False)
	If Not _ClipBoard_Open(0) Then
		$err = @error
		$err_txt = "_ClipBoard_Open failed!"
	EndIf
	If Not _ClipBoard_Empty() Then
		$err = @error
		$err_txt = "_ClipBoard_Empty failed!"
	EndIf
	If Not _ClipBoard_SetDataEx($hHBITMAP, $CF_BITMAP) Then
		$err = @error
		$err_txt = "_ClipBoard_SetDataEx failed!"
	EndIf
	_ClipBoard_Close()
	_WinAPI_DeleteObject($hHBITMAP)
	If Not $err Then
		$pos = MouseGetPos()
		ToolTip("Score copied! Paste wherever you'd like to share (Ctrl+V)", $pos[0], $pos[1])
	Else
		ToolTip("An error has occured.", $pos[0], $pos[1])
	EndIf
EndFunc   ;==>Share
#EndRegion MAIN FUNCTIONS

#Region STYLE FUNCTIONS
Func ApplyStyle()
	AdlibUnRegister("RainbowAnimate")
	For $i = 1 To 3
		GUICtrlSetBkColor(Eval("Button" & $i), "0xc6c0b6")
	Next
	GUICtrlSetBkColor($listMoves, "0xe5e0d7")
EndFunc   ;==>ApplyStyle

Func ButClick($b)
	If GUICtrlRead($checkMute) = 4 Then SoundPlay($sClick)
	GUICtrlSetState(Eval("but" & $b & "Down"), $GUI_SHOW)
	GUICtrlSetState(Eval("but" & $b), $GUI_HIDE)
	Sleep(50)
	GUICtrlSetState(Eval("but" & $b), $GUI_SHOW)
	GUICtrlSetState(Eval("but" & $b & "Down"), $GUI_HIDE)
EndFunc   ;==>ButClick

Func RainbowAnimate()
	_ArrayShuffle($rb_arr)
	GUICtrlSetBkColor($Button1, $rb_arr[0])
	GUICtrlSetBkColor($Button2, $rb_arr[1])
	GUICtrlSetBkColor($Button3, $rb_arr[2])
EndFunc   ;==>RainbowAnimate

Func MushroomAnimate()
	Global $mTimer = TimerInit()
	MushroomAnimate_t()
	AdlibRegister("MushroomAnimate_t", 250)
EndFunc   ;==>MushroomAnimate

Func MushroomAnimate_t()
	GUICtrlSetColor($labTurns, "0x00ff06")
	If TimerDiff($mTimer) >= 1000 Then
		GUICtrlSetColor($labTurns, "")
		AdlibUnRegister("MushroomAnimate_t")
	EndIf
EndFunc   ;==>MushroomAnimate_t

Func BuffAnimate()
	Global $bTimer = TimerInit()
	BuffAnimate_t()
	AdlibRegister("BuffAnimate_t", 250)
EndFunc   ;==>BuffAnimate

Func BuffAnimate_t()
	GUICtrlSetColor($labCurrent, "0x00ff06")
	If TimerDiff($bTimer) >= 1000 Then
		GUICtrlSetColor($labCurrent, "")
		AdlibUnRegister("BuffAnimate_t")
	EndIf
EndFunc   ;==>BuffAnimate_t

Func AnkhAnimate()
	Global $aTimer = TimerInit()
	AnkhAnimate_t()
	AdlibRegister("AnkhAnimate_t", 250)
EndFunc   ;==>AnkhAnimate

Func AnkhAnimate_t()
	GUICtrlSetColor($labCurrent, "0xafe0ff")
	If TimerDiff($aTimer) >= 1000 Then
		GUICtrlSetColor($labCurrent, "")
		AdlibUnRegister("AnkhAnimate_t")
	EndIf
EndFunc   ;==>AnkhAnimate_t

Func DebuffAnimate()
	Global $dTimer = TimerInit()
	DebuffAnimate_t()
	AdlibRegister("DebuffAnimate_t", 250)
EndFunc   ;==>DebuffAnimate

Func DebuffAnimate_t()
	GUICtrlSetColor($labEnemyHP, "0xff0000")
	If TimerDiff($dTimer) >= 1000 Then
		GUICtrlSetColor($labEnemyHP, "")
		AdlibUnRegister("DebuffAnimate_t")
	EndIf
EndFunc   ;==>DebuffAnimate_t

Func TimeAnimate()
	Global $tTimer = TimerInit()
	TimeAnimate_t()
	AdlibRegister("TimeAnimate_t", 250)
EndFunc   ;==>TimeAnimate

Func TimeAnimate_t()
	If TimerDiff($tTimer) < 1000 Then
		GUICtrlSetState($labTimer_Plus, $GUI_SHOW)
	Else
		GUICtrlSetState($labTimer_Plus, $GUI_HIDE)
		AdlibUnRegister("TimeAnimate_t")
	EndIf
EndFunc   ;==>TimeAnimate_t

Func OverkillAnimate()
	Global $oTimer = TimerInit()
	GUICtrlSetState($labOverkill, $GUI_SHOW)
	OverkillAnimate_t()
	AdlibRegister("OverkillAnimate_t", 250)
EndFunc   ;==>OverkillAnimate

Func OverkillAnimate_t()
	GUICtrlSetState($labOverkill, $GUI_SHOW)
	If TimerDiff($oTimer) >= 1000 Then
		GUICtrlSetState($labOverkill, $GUI_HIDE)
		AdlibUnRegister("OverkillAnimate_t")
	EndIf

EndFunc   ;==>OverkillAnimate_t
#EndRegion STYLE FUNCTIONS

#Region ITEM FUNCTIONS
Func RollForRarity()
	If $enemy_6_defeated = True Then
		Victory()
	ElseIf $enemy_5_defeated = True Then
		Local $roll = Random(60, 140, 1)
		RollForItem($roll)
	ElseIf $enemy_4_defeated = True Then
		Local $roll = Random(50, 125, 1)
		RollForItem($roll)
	ElseIf $enemy_3_defeated = True Then
		Local $roll = Random(20, 100, 1)
		RollForItem($roll)
	ElseIf $enemy_2_defeated = True Then
		Local $roll = Random(15, 95, 1)
		RollForItem($roll)
	Else
		Local $roll = Random(0, 86, 1)
		RollForItem($roll)
	EndIf
EndFunc   ;==>RollForRarity

Func RollForItem($no)
	If $no > 80 Then
		$q = Random(0, UBound($item_epic) - 1, 1)
		GiveItem($item_epic, $q)
	ElseIf $no > 50 Then
		$q = Random(0, UBound($item_rare) - 1, 1)
		GiveItem($item_rare, $q)
	Else
		$q = Random(0, UBound($item_normal) - 1, 1)
		GiveItem($item_normal, $q)
	EndIf
EndFunc   ;==>RollForItem

Func GiveItem(ByRef $r, $i)
	If _ArrayMaxIndex($r) > -1 Then
		$loot = $r[$i]
		If $loot = "Cappuccino" Then
			GUICtrlSetState($butInv1, $GUI_SHOW)
			$desc = $dCappuccino
			$pic = @ScriptDir & "\media\bmp\cappuccino.res"
		ElseIf $loot = "Stick and Stone" Then
			GUICtrlSetState($butInv2, $GUI_SHOW)
			$desc = $dStickStone
			$pic = @ScriptDir & "\media\bmp\stickandstone.res"
		ElseIf $loot = "Deep Breath" Then
			GUICtrlSetState($butInv3, $GUI_SHOW)
			$desc = $dDeepBreath
			$pic = @ScriptDir & "\media\bmp\breath.res"
		ElseIf $loot = "Ankh" Then
			GUICtrlSetState($butInv4, $GUI_SHOW)
			$desc = $dAnkh
			$pic = @ScriptDir & "\media\bmp\ankh.res"
		ElseIf $loot = "Energy Drink" Then
			GUICtrlSetState($butInv5, $GUI_SHOW)
			$desc = $dEnergyDrink
			$pic = @ScriptDir & "\media\bmp\energydrink.res"
		ElseIf $loot = "Voodoo Doll" Then
			GUICtrlSetState($butInv6, $GUI_SHOW)
			$desc = $dVoodooDoll
			$pic = @ScriptDir & "\media\bmp\voodoodoll.res"
		ElseIf $loot = "Zen Garden" Then
			GUICtrlSetState($butInv7, $GUI_SHOW)
			$desc = $dZenGarden
			$pic = @ScriptDir & "\media\bmp\zengarden.res"
		ElseIf $loot = "Green Mushroom" Then
			GUICtrlSetState($butInv8, $GUI_SHOW)
			$desc = $dGreenMushroom
			$pic = @ScriptDir & "\media\bmp\greenmushroom.res"
		ElseIf $loot = "Crack" Then
			GUICtrlSetState($butInv9, $GUI_SHOW)
			$desc = $dCrack
			$pic = @ScriptDir & "\media\bmp\crack.res"
		ElseIf $loot = "Sinister Curse" Then
			GUICtrlSetState($butInv10, $GUI_SHOW)
			$desc = $dSinisterCurse
			$pic = @ScriptDir & "\media\bmp\sinistercurse.res"
		ElseIf $loot = "Nirvana" Then
			GUICtrlSetState($butInv11, $GUI_SHOW)
			$desc = $dNirvana
			$pic = @ScriptDir & "\media\bmp\nirvana.res"
		ElseIf $loot = "Rainbow Star" Then
			GUICtrlSetState($butInv12, $GUI_SHOW)
			$desc = $dRainbowStar
			$pic = @ScriptDir & "\media\bmp\rainbowstar.res"
		Else
			MsgBox(0, "ERROR", "GiveItem Error")
		EndIf
		If $loot = "Cappuccino" Or $loot = "Stick and Stone" Or $loot = "Deep Breath" Or $loot = "Ankh" Then
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sItemNormal)
		EndIf
		If $loot = "Energy Drink" Or $loot = "Voodoo Doll" Or $loot = "Zen Garden" Or $loot = "Green Mushroom" Then
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sItemRare)
		EndIf
		If $loot = "Crack" Or $loot = "Sinister Curse" Or $loot = "Nirvana" Or $loot = "Rainbow Star" Then
			If GUICtrlRead($checkMute) = 4 Then SoundPlay($sItemEpic)
		EndIf
		_ArrayDelete($r, $i)
		GUICtrlSetImage($picLoot, $pic)
		GUICtrlSetData($nameLoot, $loot)
		GUICtrlSetData($descLoot, $desc)
		RelativePosition()
		GUISetState(@SW_SHOW, $GUI_ENEMYDEFEATED)
	Else
		RollForRarity()
		Sleep(100)
	EndIf
EndFunc   ;==>GiveItem

Func UseItem($i)
	$preval = GUICtrlRead($labCurrent)
	$preval_e = GUICtrlRead($labEnemyHP)
	$preturns = GUICtrlRead($labTurns)
	If $i = "Cappuccino" Then
		GUICtrlSetData($labCurrent, GUICtrlRead($labCurrent) + 20)
		GUICtrlSetData($listMoves, $i & ": " & $preval & " -> " & GUICtrlRead($labCurrent))
		GUICtrlSetState($butInv1, $GUI_HIDE)
		_ArrayAdd($item_normal, "Cappuccino")
	ElseIf $i = "Stick and Stone" Then
		GUICtrlSetData($labEnemyHP, GUICtrlRead($labEnemyHP) - 20)
		GUICtrlSetData($listMoves, $i & ": [" & $preval_e & "] -> [" & GUICtrlRead($labEnemyHP) & "]")
		GUICtrlSetState($butInv2, $GUI_HIDE)
		_ArrayAdd($item_normal, "Stick and Stone")
	ElseIf $i = "Deep Breath" Then
		$time += 1
		$sec += 1
		GUICtrlSetData($listMoves, $i & ": " & "+1s")
		GUICtrlSetState($butInv3, $GUI_HIDE)
		_ArrayAdd($item_normal, "Deep Breath")
	ElseIf $i = "Energy Drink" Then
		GUICtrlSetData($labCurrent, GUICtrlRead($labCurrent) + 50)
		GUICtrlSetData($listMoves, $i & ": " & $preval & " -> " & GUICtrlRead($labCurrent))
		GUICtrlSetState($butInv5, $GUI_HIDE)
		_ArrayAdd($item_rare, "Energy Drink")
	ElseIf $i = "Voodoo Doll" Then
		GUICtrlSetData($labEnemyHP, GUICtrlRead($labEnemyHP) - 50)
		GUICtrlSetData($listMoves, $i & ": [" & $preval_e & "] -> [" & GUICtrlRead($labEnemyHP) & "]")
		GUICtrlSetState($butInv6, $GUI_HIDE)
		_ArrayAdd($item_rare, "Voodoo Doll")
	ElseIf $i = "Zen Garden" Then
		$time += 2
		$sec += 2
		GUICtrlSetData($listMoves, $i & ": " & "+2s")
		GUICtrlSetState($butInv7, $GUI_HIDE)
		_ArrayAdd($item_rare, "Zen Garden")
	ElseIf $i = "Crack" Then
		GUICtrlSetData($labCurrent, GUICtrlRead($labCurrent) + 100)
		GUICtrlSetData($listMoves, $i & ": " & $preval & " -> " & GUICtrlRead($labCurrent))
		GUICtrlSetState($butInv9, $GUI_HIDE)
		_ArrayAdd($item_epic, "Crack")
	ElseIf $i = "Sinister Curse" Then
		GUICtrlSetData($labEnemyHP, GUICtrlRead($labEnemyHP) - 100)
		GUICtrlSetData($listMoves, $i & ": [" & $preval_e & "] -> [" & GUICtrlRead($labEnemyHP) & "]")
		GUICtrlSetState($butInv10, $GUI_HIDE)
		_ArrayAdd($item_epic, "Sinister Curse")
	ElseIf $i = "Nirvana" Then
		$time += 3
		$sec += 3
		GUICtrlSetData($listMoves, $i & ": " & "+3s")
		GUICtrlSetState($butInv11, $GUI_HIDE)
		_ArrayAdd($item_rare, "Nirvana")
	ElseIf $i = "Green Mushroom" Then
		GUICtrlSetData($labTurns, GUICtrlRead($labTurns) + 2)
		GUICtrlSetData($listMoves, $i & ": " & "+2 turns")
		GUICtrlSetState($butInv8, $GUI_HIDE)
		_ArrayAdd($item_rare, "Green Mushroom")
	ElseIf $i = "Rainbow Star" Then
		Global $rainbow = True
		GUICtrlSetData($listMoves, "Rainbow turn added!")
		GUICtrlSetData($labTurns, GUICtrlRead($labTurns) + 1)
		GUICtrlSetState($butInv12, $GUI_HIDE)
		_ArrayAdd($item_epic, "Rainbow Star")
	ElseIf $i = "Ankh" Then
		GUICtrlSetData($labCurrent, 100)
		GUICtrlSetData($listMoves, $i & ": " & $preval & " -> " & GUICtrlRead($labCurrent))
		GUICtrlSetState($butInv4, $GUI_HIDE)
		_ArrayAdd($item_normal, "Ankh")
	Else
		MsgBox(0, "error", "UseItem() error")
	EndIf
	GUICtrlSendMsg($listMoves, $WM_VSCROLL, $SB_LINEDOWN, 0)
EndFunc   ;==>UseItem
#EndRegion ITEM FUNCTIONS

#Region TIMER FUNCTIONS
Func StartTimer()
	Global $sec = $time
	GUICtrlSetState($labTimer, $GUI_ENABLE)
	GUICtrlSetData($labTimer, StringFormat("%.1f", $sec))
	AdlibRegister("Countdown", 100)
EndFunc   ;==>StartTimer

Func Countdown()
	If $sec <= 0.1 Then
		AdlibUnRegister("Countdown")
		Sleep(100)
		If GUICtrlRead($checkMute) = 4 Then SoundPlay($sGameOver)
		DisableButtons()
		RelativePosition()
		GUISetState(@SW_SHOW, $GUI_TIME)
		$sec += 0.1
	EndIf
	If $sec < 2.0 Then
		GUICtrlSetColor($labTimer, "0xa70a0a")
	Else
		GUICtrlSetColor($labTimer, "")
	EndIf
	$sec -= 0.1
	GUICtrlSetData($labTimer, StringFormat("%.1f", $sec))
EndFunc   ;==>Countdown

Func ResetTimer()
	AdlibUnRegister("Countdown")
	GUICtrlSetData($labTimer, StringFormat("%.1f", $time))
	StartTimer()
EndFunc   ;==>ResetTimer
#EndRegion TIMER FUNCTIONS

#Region TRAY FUNCTIONS
Func Donate() ;opens 'donate' msgbox, triggered via tray
	If MsgBox($MB_SYSTEMMODAL + $MB_YESNO + $MB_ICONINFORMATION, "Open Browser request", "Click Yes to allow this program to open URL in your default browser.") = 6 Then
		ShellExecute("https://www.paypal.com/donate?hosted_button_id=LZHSKZXSWD4QA")
	EndIf
EndFunc   ;==>Donate

Func About() ;opens 'about' msgbox, triggered via tray
	MsgBox($MB_SYSTEMMODAL, "About", "TabulatioN version " & $version & @CRLF & @CRLF & _
			"Developed by GfG Design" & @CRLF & _
			"100% free Donationware" & @CRLF & @CRLF & _
			"WretchX on GitHub" & @CRLF & @CRLF & _
			"For custom software requests" & @CRLF & _
			"message WretcH#4128 on Discord" & @CRLF & @CRLF & _
			"For custom graphics art, visit" & @CRLF & _
			"gfgdesign.myportfolio.com" & @CRLF & @CRLF & _
			"Special thanks to my friends" & @CRLF & _
			"Who helped beta test my first game")
EndFunc   ;==>About
#EndRegion TRAY FUNCTIONS

#Region INI FUNCTIONS
Func ini_read() ;reads values from ini
	Global $search = FileFindFirstFile(@ScriptDir & "\settings.ini")
	Global $sFileName = FileFindNextFile($search)
	If $search = -1 Then
		MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR, "Error", "settings.ini not found" & @CRLF & "If you are not running this directly from the program folder, try creating a shortcut instead." & @CRLF & @CRLF & "CODE: 111")
		Exit 941
	EndIf
	Global $iniMute = IniRead($sFileName, "settings", "mute", "Default")
	Global $iniVolume = IniRead($sFileName, "settings", "volume", "Default")
EndFunc   ;==>ini_read

Func ini_write() ;writes values to ini from GUI controls
	IniWrite(@ScriptDir & "\settings.ini", "settings", "mute", GUICtrlRead($checkMute))
	IniWrite(@ScriptDir & "\settings.ini", "settings", "volume", GUICtrlRead($Slider1))
EndFunc   ;==>ini_write

Func create_ini() ;creates ini file. used on first-time startup or if ini is not detected.
	_FileCreate("settings.ini")
	$testfile = (@ScriptDir & "\settings.ini")
	FileWrite($testfile, "[settings]" & @CRLF)
	FileWrite($testfile, "mute=4" & @CRLF)
	FileWrite($testfile, "volume=50" & @CRLF)
	FileWrite($testfile, "played=no" & @CRLF)
EndFunc   ;==>create_ini
#EndRegion INI FUNCTIONS