#SingleInstance, Force
SetBatchLines, -1
#NoEnv
#NoTrayIcon
#Persistent
#Include gdip.ahk
SetWorkingDir %A_ScriptDir%
pname:="JConvert2Radar"
palis:="HD Radar Converter"
pvers:="1.0.2.2"
Built:="Dec, 2017"
copyr:="2017"
Menu, FileMenu, Add, &Open, Browse
Menu, FileMenu, Add, E&xit, Guiclose
Menu, EditMenu, add, Sli&ce, MenuSlice
Menu, EditMenu, add, Conve&rt, MenuConvert
Menu, EditMenu, disable, Sli&ce
Menu, EditMenu, disable, Conve&rt
Menu, AboutMenu, add, Help, MenuHelp
Menu, AboutMenu, add, About, MenuAbout
Menu, MenuBar, Add, &File, :FileMenu
Menu, menubar, add, &Edit, :EditMenu
Menu, menubar, add, &Help, :AboutMenu
Gui, menu, menubar
ifnotexist % A_WorkingDir . "\images\radartxd"
filecreatedir, % A_WorkingDir . "\images\radartxd"
ifnotexist % A_WorkingDir . "\images\radarimg"
filecreatedir, % A_WorkingDir . "\images\radarimg"
gui,add,text,y7 w100,Select Images	:
gui,add,edit,vname x+m y5 w190 ReadOnly
gui,add,text,xm w100,Tile Option	:
gui,add,dropdownlist,vtiles Choose3 x+m gtile,128|256|512
gui,add,button,x+m gbrowse vbrowseb w60,Browse
gui,add,button,y+m x120 gslice vsliceb w90 disabled, Slice
gui,add,button,x+m gconvertx vconvertb w90 disabled, Convert
gui,show,,%palis% - %pvers%
return
menuabout:
disablem()
disableb()
aboutmessage=
( 
Name: %pname%
Alias: %palis%
Version: %pvers%
Created by jheb

Built on: %built%
)
msgbox,,About JConvert2Radar,%aboutmessage%
enablem()
enableb()
return
convertx:
gui,submit,nohide
if (forceconvert=1)
	gosub,menuconvert
else if (forceconvert=0)
	gosub,convert
return
menuhelp:
disablem()
disableb()
helpmessage=
(
Image size must be 1536*1536 / 3072*3072 / 6144*6144px

0. Place the radar images to images folder;
1. Open Convert2Radar.exe,
2. Browse and Select radar images/picture,
3. Click on Slice to slice the images into 144 pieces,
4. Click on Convert to start convert these pieces to txd files.

More information: http://forum.ls-rp.com/viewtopic.php?f=222&t=650232
)
msgbox,64,%palis% - Readme, %helpmessage%
enablem()
enableb()
return
menuslice:
gui,submit,nohide
if menuready
	gosub slice
menuconvert:
gui,submit,nohide
if menuready
	stringleft,filename,resname,5
if ((filename="radar") && (resdir=sliced)) {
	loop, 144 {
		ifnotexist %sliced%\radar%a_index%.%resext%
		{
			msgbox,, Error, Missing file(s) at radar%a_index%.%resext%
			break
		}
		filesready:=a_index
	}
	if (filesready=144)
		gosub, convert
}
else {
	Msgbox,4,Convert to TXD, This option will automatically convert your image to 144 radar txd files.`nAre you sure?
	IfMsgBox, Yes
	{
		Silentmode:=1
		gosub,slice
	}
}
return
tile:
gui,submit,nohide
tiles:=tiles
return
Browse:
gui,submit,nohide
disableb()
disablem()
FileSelectFile,resource,1,%a_workingdir%\images,,Images Files (*.png; *.jpg; *.jpeg; *.tga)
SplitPath,resource,resname,resdir,resext,resnoext,resdrive
if ((resext="jpg") || (resext="jpeg") || (resext="png") || (resext="tga")) {
	Source:=resource
	Output:=A_WorkingDir . "\images\radartxd"
	Sliced:=A_WorkingDir . "\images\radarimg"
	Resext:=resext
	menuready:=1
	guicontrol,,sliceb,Slice
	guicontrol,,convertb,Convert
	guicontrol,,name,%resname%
	enableb()
	enablem()
	If !pToken := Gdip_Startup() {
		MsgBox, 48, Gdiplus library error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		ExitApp
	}
	pBitmapR 	:= Gdip_CreateBitmapFromFile(Source)
	Width 		:= Gdip_GetImageWidth(pBitmapR)
	Height 		:= Gdip_GetImageHeight(pBitmapR)
	mxl:=tiles*12
	if ((width<mxl) || (height<mxl))
		guicontrol,disable,sliceb
	forceconvert:=1
}
else {
	resource:=
	resname:=
	resdir:=
	resext:=
	resnoext:=
	resdrive:=
	source:=
	output:=
	menuready:=
	guicontrol,,name
	enableb("convertb|sliceb")
	enablem("Conve&rt|Sli&ce")
	guicontrol,,sliceb,Slice
	guicontrol,,convertb,Convert
}
return
Slice:
gui,submit,nohide
disableb()
disablem()
If !pToken := Gdip_Startup() {
	MsgBox, 48, Gdiplus library error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
pBitmapR 	:= Gdip_CreateBitmapFromFile(Source)
Width 		:= Gdip_GetImageWidth(pBitmapR)
Height 		:= Gdip_GetImageHeight(pBitmapR)
mxl:=tiles*12
if ((width<mxl) || (height<mxl)) {
	MsgBox,, Error!,Images Size doesn't match or too small! `nImages should be %mxl%x%mxl%(px).
	reload
	return
}
sx:=0
sy:=0
mxl:=tiles*11
pBitmapO	:= Gdip_CreateBitmap(tiles, tiles)
GraphO		:= Gdip_GraphicsFromImage(pBitmapO)
loop, 145 {
	ifnotexist %Source%
	{
		msgbox,,Error, Radar images resource doesn't Exist.
		break
	}
	if (a_index=145)
		break
	tooltip,Slicing Radar Images... [radar%a_index%.%resext% (x%sx% | y%sy%)]
	Gdip_DrawImage(GraphO, pBitmapR, 0, 0, tiles, tiles, sx, sy, tiles, tiles)
	Gdip_SaveBitmapToFile(pBitmapO, sliced . "\radar" . a_index . "." . resext)
	if (sx<mxl)
		sx:=sx+tiles
	else if (sx>=mxl) {
		if (sy>=mxl)
		break
		sx:=0
		sy:=sy+tiles
	}
	curslice:=a_index
}
Gdip_DisposeImage(pBitmapR)
Gdip_DisposeImage(pBitmapO)
Gdip_DeleteGraphics(GraphO)
tooltip,Slicing Radar Images... [Success]
settimer,tooltipoff,5000
enableb("sliceb")
enablem("Sli&ce")
forceconvert:=0
guicontrol,,sliceb,Sliced.
if silentmode
	gosub,convert
return
Guiclose:
exitapp
Convert:
gui,submit,nohide
disableb()
disablem()
x:=0
i:=""
a:=""
ToolTip,Please Wait`, Converting images... [],,,1
loop, 144 {
	a:=a_index
	if (x<10)
	i:="0" . x
	else
	i:=x
	IfNotExist % sliced . "\radar" . a . "." . resext
	{
		msgbox,, Error,File not exist %a% `n("%sliced%\radar%a%.%resext%")
		break
	}
	run, TXDCreate.exe "%sliced%\radar%a%.%resext%" "%output%\radar%i%.txd", %A_WorkingDir%, Hide
	x:=x+1
	ToolTip,Please Wait`, Converting images... [radar%i%.txd],,,1
	while processexist("txdcreate.exe")
	sleep 100
}
ToolTip,Please Wait`, Converting images... [Completed],,,1
settimer,tooltipoff,5000
if (x>=143)
	msgbox,, Success,All radar images successfully converted to txd files.
else
	msgbox,, Error, radar images convert failed at %x%!
enableb("sliceb|convertb")
enablem("Sli&ce|Conve&rt")
guicontrol,,sliceb,Sliced.
guicontrol,,convertb,Converted.
return
tooltipoff:
settimer,tooltipoff,off
tooltip
return
disableb(x="")
{
	guicontrol,disable,browseb
	guicontrol,disable,convertb
	guicontrol,disable,tiles
	guicontrol,disable,sliceb
	if (x="ERROR")||!x
		return 0
	stringsplit,x,x,`|
	loop %x0%
		guicontrol,disable,% x%a_index%
}
enableb(x="")
{
	guicontrol,enable,browseb
	guicontrol,enable,convertb
	guicontrol,enable,tiles
	guicontrol,enable,sliceb
	if (x="ERROR")||!x
		return 0
	stringsplit,x,x,`|
	loop %x0%
		guicontrol,disable,% x%a_index%
}
disablem(x="")
{
	menu,FileMenu,disable,&Open
	menu,EditMenu,disable,Sli&ce
	menu,EditMenu,disable,Conve&rt
	if (x="ERROR")||!x
		return 0
	stringsplit,x,x,`|
	loop %x0%
		menu,EditMenu,enable,% x%a_index%
	if (x="&Open")
		menu,FileMenu,enable,&Open
}
enablem(x="")
{
	menu,FileMenu,enable,&Open
	menu,EditMenu,enable,Sli&ce
	menu,EditMenu,enable,Conve&rt
	if (x="ERROR")||!x
		return 0
	stringsplit,x,x,`|
	loop %x0%
		menu,EditMenu,disable,% x%a_index%
	if (x="&Open")
		menu,FileMenu,disable,&Open
}
ProcessExist(Name){
	Process,Exist,%Name%
	return Errorlevel
}
