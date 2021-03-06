#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

exec := "waifu2x-ncnn-vulkan.exe"

Gui, Add, Text,, Input:
Gui, Add, Edit, vInput w500 x50 yp+0
Gui, Add, Button, gSelectinput x+m, Select File...
Gui, Add, Text, xm, Output:
Gui, Add, Edit, vOutput w500 x50 yp+0
Gui, Add, Button, gSelectoutput x+m, Select File...
Gui, Add, Text, xm, Output File Format:
Gui, Add, Radio, xm vFormat gChangeFormat +Checked, WebP
Gui, Add, Radio, x100 yp+0 gChangeFormat, PNG
Gui, Add, Text, xm, Scale:
Gui, Add, Radio, vScale gChangeFormat, x1
Gui, Add, Radio, x100 yp+0 +Checked gChangeFormat, x2
Gui, Add, Text, xm, Model:
Gui, Add, Radio, xm vModel gChangeFormat +Checked, cunet
Gui, Add, Radio, x100 yp+0 gChangeFormat, upconv_7_anime_style_art_rgb
Gui, Add, Radio, x300 yp+0 gChangeFormat, upconv_7_photo
Gui, Add, Text, xm, Noise Reduction:
Gui, Add, DDL, x+m vNoise Choose2, -1|0|1|2|3
Gui, Add, Checkbox, x+m vTTA gChangeFormat, Use TTA
Gui, Add, Button, gChangeFormat w50 vStart x+m, Start
Gui, Show
return

Selectinput:
FileSelectFile, inputfile,,,, Picture (*.png; *.webp; *.jpg; *.gif; *.jfif; *.jpeg)
If ErrorLevel
Return
ChangeFormat:
SplitPath, inputfile,, outdir,, outname
Gui, Submit, NoHide
Switch Format
{
case 1: ext := "webp"
case 2: ext := "png"
}
Switch Scale
{
case 1: scalar := "1"
case 2: scalar := "2"
}
Switch Model
{
case 1: Model := "models-cunet"
case 2: Model := "models-upconv_7_anime_style_art_rgb"
case 3: Model := "models-upconv_7_photo"
}
modelshort := StrReplace(Model, "models-")
If (TTA = 1)
settta := "-x", settta2 := "(TTA)"
else
settta := "", settta2 := ""
outputfile := outdir "\" outname "(x" scalar ")(" modelshort ")" settta2 "." ext
if (inputfile != "") 
{
GuiControl, Text, Input, "%inputfile%"
GuiControl, Text, Output, "%outputfile%"
}
if (A_GuiControl = "Start")
{
If !FileExist(exec)
MsgBox, %exec% was not found!
else
{
GuiControl, Disable, Start
run, %exec% -i "%inputfile%" -o "%outputfile%" -n %Noise% -s %scalar% -f %ext% %settta%
Process, Exist, %exec%
While ErrorLevel
{
Sleep 100
Process, Exist, %exec%
}
GuiControl, Enable, Start
}
}
return

Selectoutput:
FileSelectFile, Outputfile, S,,, Picture (*.png; *.webp)
GuiControl, Text, Output, "%outputfile%"
return

GuiClose:
ExitApp

GuiDropFiles:
If InStr(A_GuiEvent, "`n")
return
inputfile := A_GuiEvent
GoTo, ChangeFormat
