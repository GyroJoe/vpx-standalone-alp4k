Option Explicit
Randomize
Const VolDiv = 2000    ' Lower numper louder ballrolling sound
Const VolCol    = 3    ' Ball collition divider ( voldiv/volcol )

' The rest of the values are multipliers
'
'  .5 = lower volume
' 1.5 = higher volume

Const VolBump   = 2    ' Bumpers volume.
Const VolRol    = 1    ' Rollovers volume.
Const VolGates  = 1    ' Gates volume.
Const VolMetal  = 1    ' Metals volume.
Const VolRB     = 1    ' Rubber bands volume.
Const VolRH     = 1    ' Rubber hits volume.
Const VolPo     = 1    ' Rubber posts volume.
Const VolPi     = 1    ' Rubber pins volume.
Const VolPlast  = 1    ' Plastics volume.
Const VolTarg   = 1    ' Targets volume.
Const VolWood   = 1    ' Woods volume.
Const VolFlip   = 1    ' Flipper volume.

On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "Can't open controller.vbs"
On Error Goto 0

Const cGameName="goinnuts",UseSolenoids=2,UseLamps=1,UseGI=0,SSolenoidOn="SolOn",SSolenoidOff="SolOff",SFlipperOn="FlipperUp",SFlipperOff="FlipperDown"
Const SCoin="coin3",cCredits=""

LoadVPM "01120100","sys80.vbs",3.02

Dim DesktopMode: DesktopMode = Table1.ShowDT

Dim hiddenvalue

If DesktopMode = True Then 'Show Desktop components
metalrails.visible=1
hiddenvalue=0
Else
metalrails.visible=0
hiddenvalue=1
End if

'****************************** Script for VR Rooms  ********************
' VR Option
Dim VRRoom, Object, UseVPMDMD

'VR Room
VRRoom = 0			' 0 = desktop/fullscreen, 1 = sphere, 2 = minimal VR Room

If VRRoom = 1 Or VRRoom = 2 then UseVPMDMD = true Else UseVPMDMD = DesktopMode

If VRRoom = 0 Then
	for each Object in ColVR : object.visible = 0 : next
End If

If VRRoom = 1 Then
	for each Object in ColRoom1 : object.visible = 1 : next
	for each Object in ColRoomMinimal : object.visible = 0 : next
	for each Object in ColOutLanes : object.visible = 0 : next
	VR_Sphere.image = "Sphere"
	SaveValue "Nuts", "V1.0.0", 0
End If

If VRRoom = 2 Then
	for each Object in ColRoom1 : object.visible = 0 : next
	for each Object in ColRoomMinimal : object.visible = 1 : next
	for each Object in ColOutLanes : object.visible = 0 : next	
	SaveValue "Nuts", "V1.0.0", 1
End If



' using table width and height in script slows down the performance
dim tablewidth: tablewidth = Table1.width
dim tableheight: tableheight = Table1.height

SolCallback(1)="dtG"
SolCallback(2)="dtR"
SolCallback(5)="dtB"
SolCallback(6)="dtY"
SolCallback(13)="dtW"
SolCallback(8)="VpmSolSound SoundFX(""knocker"",DOFKnocker),"
SolCallback(9)="HandleTrough"

'SolCallback(sLLFlipper)="VpmSolFlipper LeftFlipper,nothing,"
'SolCallback(sLRFlipper)="SolRightF"

  SolCallback(sLRFlipper) = "SolRFlipper"
  SolCallback(sLLFlipper) = "SolLFlipper"

  Sub SolLFlipper(Enabled)
     If Enabled Then
        PlaySoundAtVol SoundFx("fx2_flipperup2", DOFContactors), LeftFlipper, VOLFLip
		LF.Fire
     Else
        PlaySoundAtVol SoundFX("fx2_flipperdown2",DOFContactors), LeftFlipper, VolFlip
		LeftFlipper.RotateToStart
     End If
  End Sub

  Sub SolRFlipper(Enabled)
     If Enabled Then
        PlaySoundAtVol SoundFX("fx2_flipperup2",DOFContactors), RightFlipper, VolFlip
		RF.Fire
		RightFlipper1.rotatetoend
		RightFlipper2.rotatetoend
		 PlaySoundAtVol "fx2_flipperup2", FlipperRB1, VolFlip
		 PlaySoundAtVol "fx2_flipperup2", FlipperRB2, VolFlip
     Else
        PlaySoundAtVol SoundFX("fx2_flipperdown2",DOFContactors), RightFlipper, VolFlip
		RightFlipper.RotateToStart
		rightflipper1.rotatetostart
		rightflipper2.rotatetostart
		    PlaySoundAtVol "fx2_flipperdown2", FlipperRB1, VolFlip
		    PlaySoundAtVol "fx2_flipperdown2", FlipperRB2, VolFlip
	 End If
  End Sub

'******************************************************
'			FLIPPER TRICKS
'******************************************************

RightFlipper.timerinterval=1
Rightflipper.timerenabled=True

sub RightFlipper_timer()
	FlipperTricks LeftFlipper, LFPress, LFCount, LFEndAngle, LFState
	FlipperTricks RightFlipper, RFPress, RFCount, RFEndAngle, RFState
end sub

dim LFPress, RFPress, LFCount, RFCount
dim LFState, RFState
dim EOST, EOSA,Frampup, FElasticity,FReturn
dim RFEndAngle, LFEndAngle

EOST = leftflipper.eostorque
EOSA = leftflipper.eostorqueangle
Frampup = LeftFlipper.rampup
FElasticity = LeftFlipper.elasticity
FReturn = LeftFlipper.return
Const EOSTnew = 1 
Const EOSAnew = 1
Const EOSRampup = 0
Dim SOSRampup
SOSRampup = 2.5
Const LiveCatch = 16
Const LiveElasticity = 0.45
Const SOSEM = 0.815
Const EOSReturn = 0.045

LFEndAngle = Leftflipper.endangle
RFEndAngle = RightFlipper.endangle

Sub FlipperActivate(Flipper, FlipperPress)
	FlipperPress = 1
	Flipper.Elasticity = FElasticity

	Flipper.eostorque = EOST 	
	Flipper.eostorqueangle = EOSA 	
End Sub

Sub FlipperDeactivate(Flipper, FlipperPress)
	FlipperPress = 0
	Flipper.eostorqueangle = EOSA
	Flipper.eostorque = EOST*EOSReturn/FReturn

	
	If Abs(Flipper.currentangle) <= Abs(Flipper.endangle) + 0.1 Then
		Dim BOT, b
		BOT = GetBalls
			
		For b = 0 to UBound(BOT)
			If Distance(BOT(b).x, BOT(b).y, Flipper.x, Flipper.y) < 55 Then 'check for cradle
				If BOT(b).vely >= -0.4 Then BOT(b).vely = -0.4
			End If
		Next
	End If
End Sub

Sub FlipperTricks (Flipper, FlipperPress, FCount, FEndAngle, FState) 
	Dim Dir
	Dir = Flipper.startangle/Abs(Flipper.startangle)	'-1 for Right Flipper

	If Abs(Flipper.currentangle) > Abs(Flipper.startangle) - 0.05 Then
		If FState <> 1 Then
			Flipper.rampup = SOSRampup 
			Flipper.endangle = FEndAngle - 3*Dir
			Flipper.Elasticity = FElasticity * SOSEM
			FCount = 0 
			FState = 1
		End If
	ElseIf Abs(Flipper.currentangle) <= Abs(Flipper.endangle) and FlipperPress = 1 then
		if FCount = 0 Then FCount = GameTime

		If FState <> 2 Then
			Flipper.eostorqueangle = EOSAnew
			Flipper.eostorque = EOSTnew
			Flipper.rampup = EOSRampup			
			Flipper.endangle = FEndAngle
			FState = 2
		End If
	Elseif Abs(Flipper.currentangle) > Abs(Flipper.endangle) + 0.01 and FlipperPress = 1 Then 
		If FState <> 3 Then
			Flipper.eostorque = EOST	
			Flipper.eostorqueangle = EOSA
			Flipper.rampup = Frampup
			Flipper.Elasticity = FElasticity
			FState = 3
		End If

	End If
End Sub

Const LiveDistanceMin = 30  'minimum distance in vp units from flipper base live catch dampening will occur
Const LiveDistanceMax = 114  'maximum distance in vp units from flipper base live catch dampening will occur (tip protection)

Sub CheckLiveCatch(ball, Flipper, FCount, parm) 'Experimental new live catch
	Dim Dir
	Dir = Flipper.startangle/Abs(Flipper.startangle)    '-1 for Right Flipper
	Dim LiveCatchBounce															'If live catch is not perfect, it won't freeze ball totally
	Dim CatchTime : CatchTime = GameTime - FCount

	if CatchTime <= LiveCatch and parm > 6 and ABS(Flipper.x - ball.x) > LiveDistanceMin and ABS(Flipper.x - ball.x) < LiveDistanceMax Then
		if CatchTime <= LiveCatch*0.5 Then						'Perfect catch only when catch time happens in the beginning of the window
			LiveCatchBounce = 0
		else
			LiveCatchBounce = Abs((LiveCatch/2) - CatchTime)	'Partial catch when catch happens a bit late
		end If

		If LiveCatchBounce = 0 and ball.velx * Dir > 0 Then ball.velx = 0
		ball.vely = LiveCatchBounce * (32 / LiveCatch) ' Multiplier for inaccuracy bounce
		ball.angmomx= 0
		ball.angmomy= 0
		ball.angmomz= 0
	End If
End Sub

Sub LeftFlipper_Collide(parm)
	CheckLiveCatch Activeball, LeftFlipper, LFCount, parm
'	LeftFlipperCollide parm
	Rubberizer2(parm)
End Sub

Sub RightFlipper_Collide(parm)
	CheckLiveCatch Activeball, RightFlipper, RFCount, parm
'	RightFlipperCollide parm
	Rubberizer2(parm)
End Sub

'*******************************************
'  VPW Rubberizer by Iaakki
'*******************************************

' iaakki Rubberizer
sub Rubberizer(parm)
	if parm < 10 And parm > 2 And Abs(activeball.angmomz) < 10 then
		'debug.print "parm: " & parm & " momz: " & activeball.angmomz &" vely: "& activeball.vely
		activeball.angmomz = activeball.angmomz * 1.2
		activeball.vely = activeball.vely * 1.2
		'debug.print ">> newmomz: " & activeball.angmomz&" newvely: "& activeball.vely
	Elseif parm <= 2 and parm > 0.2 Then
		'debug.print "* parm: " & parm & " momz: " & activeball.angmomz &" vely: "& activeball.vely
		activeball.angmomz = activeball.angmomz * -1.1
		activeball.vely = activeball.vely * 1.4
		'debug.print "**** >> newmomz: " & activeball.angmomz&" newvely: "& activeball.vely
	end if
end sub


' apophis Rubberizer
sub Rubberizer2(parm)
	if parm < 10 And parm > 2 And Abs(activeball.angmomz) < 10 then
		'debug.print "parm: " & parm & " momz: " & activeball.angmomz &" vely: "& activeball.vely
		activeball.angmomz = -activeball.angmomz * 2
		activeball.vely = activeball.vely * 1.2
		'debug.print ">> newmomz: " & activeball.angmomz&" newvely: "& activeball.vely
	Elseif parm <= 2 and parm > 0.2 Then
		'debug.print "* parm: " & parm & " momz: " & activeball.angmomz &" vely: "& activeball.vely
		activeball.angmomz = -activeball.angmomz * 0.5
		activeball.vely = activeball.vely * (1.2 + rnd(1)/3 )
		'debug.print "**** >> newmomz: " & activeball.angmomz&" newvely: "& activeball.vely
	end if
end sub

Dim dtGreen,dtRed,dtYellow,dtBlue,dtWhite,bsTrough,cbCaptive

'Primitive Flipper Code
Sub FlipperTimer_Timer
	FlipperLB.rotz = LeftFlipper.currentangle
	FlipperLR.rotz = LeftFlipper.currentangle
	FlipperRB.rotz = RightFlipper.currentangle
	FlipperRR.rotz = RightFlipper.currentangle
	FlipperRB1.rotz = RightFlipper.currentangle
	FlipperRR1.rotz = RightFlipper.currentangle
	FlipperRB2.rotz = RightFlipper2.currentangle
	FlipperRR2.rotz = RightFlipper2.currentangle
	FlipperLsh.rotz= LeftFlipper.currentangle
	FlipperRsh.rotz= RightFlipper.currentangle
	FlipperRsh1.rotz= RightFlipper.currentangle
	FlipperRsh2.rotz= RightFlipper2.currentangle
	if sw00.isdropped=1 then dropplate1.image = "blank"
	if sw10.isdropped=1 then dropplate2.image = "blank"
	if sw20.isdropped=1 then dropplate3.image = "blank"
	if sw04.isdropped=1 then dropplate4.image = "blank"
	if sw14.isdropped=1 then dropplate5.image = "blank"
	if sw24.isdropped=1 then dropplate6.image = "blank"
	if sw03.isdropped=1 then dropplate7.image = "blank"
	if sw13.isdropped=1 then dropplate8.image = "blank"
	if sw23.isdropped=1 then dropplate9.image = "blank"
	if sw02.isdropped=1 then dropplate10.image = "blank"
	if sw12.isdropped=1 then dropplate11.image = "blank"
	if sw22.isdropped=1 then dropplate12.image = "blank"
	if sw00.isdropped=0 then dropplate1.image = "sw00"
	if sw10.isdropped=0 then dropplate2.image = "sw10"
	if sw20.isdropped=0 then dropplate3.image = "sw20"
	if sw04.isdropped=0 then dropplate4.image = "sw04"
	if sw14.isdropped=0 then dropplate5.image = "sw14"
	if sw24.isdropped=0 then dropplate6.image = "sw24"
	if sw03.isdropped=0 then dropplate7.image = "sw03"
	if sw13.isdropped=0 then dropplate8.image = "sw13"
	if sw23.isdropped=0 then dropplate9.image = "sw23"
	if sw02.isdropped=0 then dropplate10.image = "sw02"
	if sw12.isdropped=0 then dropplate11.image = "sw12"
	if sw22.isdropped=0 then dropplate12.image = "sw22"
	if L15.State=1 then
			bumper6base.image="bumpbase6on"
			bumper6cap.image="bumpcap6on"
		end if
		if L15.State=0 then
			bumper6base.image="bumpbase6off"
			bumper6cap.image="bumpcap6off"
		end if
		if L19.State=1 then
			bumper1base.image="bumpbase1on"
			bumper1cap.image="bumpcap1on"
			bumper3base.image="bumpbase3on"
			bumper3cap.image="bumpcap3on"
		end if
		if L19.State=0 then
			bumper1base.image="bumpbase1off"
			bumper1cap.image="bumpcap1off"
			bumper3base.image="bumpbase3off"
			bumper3cap.image="bumpcap3off"
		end if
		if L40.State=1 Then
			bumper2base.image="bumpbase2on"
			bumper2cap.image="bumpcap2on"
		end if
		if L40.State=0 then
			bumper2base.image="bumpbase2off"
			bumper2cap.image="bumpcap2off"
		end if
		if L42.State=1 Then
			bumper5base.image="bumpbase5on"
			bumper5cap.image="bumpcap5on"
		end if
		if L42.State=0 then
			bumper5base.image="bumpbase5off"
			bumper5cap.image="bumpcap5off"
		end if
		if L24.State=1 Then
			bumper4base.image="bumpbase4on"
			bumper4cap.image="bumpcap4on"
		end if
		if L24.State=0 then
			bumper4base.image="bumpbase4off"
			bumper4cap.image="bumpcap4off"
		end if
		if L30.State=1 Then
			bumper7base.image="bumpbase7on"
			bumper7cap.image="bumpcap7on"
		end if
		if L30.State=0 then
			bumper7base.image="bumpbase7off"
			bumper7cap.image="bumpcap7off"
		end if

	DisplayTimer

End Sub

Sub DTG(enabled)
	if enabled then
		dtGreen.SolDropUp enabled
	end if
End Sub

Sub DTB(enabled)
	if enabled then
		dtBlue.SolDropUp enabled
	end if
End Sub

Sub DTW(enabled)
	if enabled then
		dtWhite.SolDropUp enabled
	end if
End Sub

Sub DTY(enabled)
	if enabled then
		dtYellow.SolDropUp enabled
	end if
End Sub

Sub DTR(enabled)
	if enabled then
		dtRed.SolDropUp enabled
	end if
End Sub

'*************
'//////////////---- LUT (Colour Look Up Table) ----//////////////
'*************
'0 = Fleep Natural Dark 1
'1 = Fleep Natural Dark 2
'2 = Fleep Warm Dark
'3 = Fleep Warm Bright
'4 = Fleep Warm Vivid Soft
'5 = Fleep Warm Vivid Hard
'6 = Skitso Natural and Balanced
'7 = Skitso Natural High Contrast
'8 = 3rdaxis Referenced THX Standard
'9 = CalleV Punchy Brightness and Contrast
'10 = HauntFreaks Desaturated
'11 = Tomate Washed Out 
'12 = VPW Original 1 to 1
'13 = Bassgeige
'14 = Blacklight
'15 = B&W Comic Book

Dim LUTset, LutToggleSound
LutToggleSound = True
LoadLUT
SetLUT


'*****************************************************************************************************
'
'*****************************************************************************************************

Sub Table1_Init
	vpmInit Me
	On Error Resume Next
	With Controller
		.GameName=cGameName
		If Err Then MsgBox "Can't start Game" & cGameName & vbNewLine & Err.Description : Exit Sub
		.SplashInfoLine="Goin' Nuts (Gottlieb 1983)"
		.HandleMechanics=0
		.HandleKeyboard=0
		.ShowDMDOnly=1
		.ShowFrame=0
		.ShowTitle=0
		.SolMask(0)=0
		.Hidden=0
		If Err Then MsgBox Err.Description
	End With
	On Error Goto 0
		Controller.SolMask(0)=0
      vpmTimer.AddTimer 2000,"Controller.SolMask(0)=&Hffffffff'" 'ignore all solenoids - then add the timer to renable all the solenoids after 2 seconds
		Controller.Run
	If Err Then MsgBox Err.Description
	On Error Goto 0

	' Main Timer init
	PinMAMETimer.Interval=PinMAMEInterval
	PinMAMETimer.Enabled=1

	' Nudging
	vpmNudge.TiltSwitch=57
	vpmNudge.Sensitivity=2
	vpmNudge.TiltObj=Array(Bumper1,Bumper2,Bumper3,Bumper4,Bumper5,Bumper6,Bumper7)

	'drop targets
	Set dtGreen=New cvpmDropTarget
	dtGreen.InitDrop Array(SW00,SW10,SW20),Array(0,10,20)
	dtGreen.initsnd SoundFX("fx2_droptarget",DOFContactors),SoundFX("fx2_DTReset",DOFContactors)

	Set dtRed=New cvpmDropTarget
	dtRed.InitDrop Array(SW01,SW11,SW21),Array(1,11,21)
	dtRed.initsnd SoundFX("fx2_droptarget1",DOFContactors),SoundFX("fx2_DTReset1",DOFContactors)

	Set dtBlue=New cvpmDropTarget
	dtBlue.InitDrop Array(SW02,SW12,SW22),Array(2,12,22)
	dtBlue.initsnd SoundFX("fx2_droptarget2",DOFContactors),SoundFX("fx2_DTReset2",DOFContactors)

	Set dtYellow=New cvpmDropTarget
	dtYellow.InitDrop Array(SW03,SW13,SW23),Array(3,13,23)
	dtYellow.initsnd SoundFX("fx2_droptarget3",DOFContactors),SoundFX("fx2_DTReset3",DOFContactors)

	Set dtWhite=New cvpmDropTarget
	dtWhite.InitDrop Array(SW04,SW14,SW24),Array(4,14,24)
	dtWhite.initsnd SoundFX("fx2_droptarget4",DOFContactors),SoundFX("fx2_DTReset4",DOFContactors)

' Trough handler
	Set bsTrough=new cvpmBallStack
	bsTrough.InitSw 0,54,0,0,0,0,0,0
	bsTrough.InitKick sw54,90,6
	bsTrough.InitExitSnd Soundfx("fx_ballrel",DOFContactors), Soundfx("fx_solenoid",DOFContactors)
	bsTrough.Balls=3

    Kicker1.CreateBall
	Kicker1.kick 180, 3
	Kicker1.enabled = 0

	If VRRoom = 1 Or VRRoom = 2  Then
		setup_backglass()
	End If


End Sub

Sub Table1_KeyDown(ByVal keycode)

	KeyDownHandler(KeyCode)

' Change LUT with magna-save buttons
	If Keycode = LeftMagnaSave Then
				LUTSet = LUTSet  + 1
		if LutSet > 15 then LUTSet = 0
				lutsetsounddir = 1
			If LutToggleSound then
				If lutsetsounddir = 1 And LutSet <> 15 Then
					Playsound "click", 0, 1, 0.1, 0.25 
				End If
			If lutsetsounddir = -1 And LutSet <> 15 Then
					Playsound "click", 0, 1, 0.1, 0.25 
				End If
			If LutSet = 15 Then
					Playsound "gun", 0, 1, 0.1, 0.25 
				End If
				LutSlctr.enabled = true
			SetLUT
			ShowLUT
		End If
	End If

	If VRRoom = 1 Or VRRoom = 2  Then
		If keycode = LeftFlipperKey Then 
			VR_CabFlipperLeft.X = VR_CabFlipperLeft.X +10	' Animate VR Left flipper
		End If
		If keycode = RightFlipperKey Then
			VR_CabFlipperRight.X = VR_CabFlipperRight.X - 10	' Animate VR Left flipper
		End If
		If Keycode = StartGameKey Then
			VR_Cab_StartButton.y = VR_Cab_StartButton.y -5	' Animate VR Startbutton
		End If
'		If keycode = rightmagnasave then						' Change VR room
'			vrroom = vrroom +1
'		if vrroom > 1 then vrroom = 0
'			VRChangeRoom
'		End If
	End If

End Sub

Sub Table1_KeyUp(ByVal keycode)

	KeyUpHandler(KeyCode)

	If VRRoom = 1 Or VRRoom = 2  Then
		If keycode = LeftFlipperKey Then 
			VR_CabFlipperLeft.X = VR_CabFlipperLeft.X -10	' Animate VR Left flipper
		End If
		If keycode = RightFlipperKey Then
			VR_CabFlipperRight.X = VR_CabFlipperRight.X +10	' Animate VR Left flipper
		End If
		If Keycode = StartGameKey Then
			VR_Cab_StartButton.y = VR_Cab_StartButton.y +5	' Animate VR Startbutton
		End If
'		If keycode = rightmagnasave then						' Change VR room
'			vrroom = vrroom +1
'		if vrroom > 1 then vrroom = 0
'			VRChangeRoom
'		End If
	End If

End Sub

'**********************************************************************************************************
'LUT selector timer
'**********************************************************************************************************

dim lutsetsounddir
sub LutSlctr_timer
	If lutsetsounddir = 1 And LutSet <> 15 Then
		Playsound "click", 0, 1, 0.1, 0.25 
	End If
	If lutsetsounddir = -1 And LutSet <> 15 Then
		Playsound "click", 0, 1, 0.1, 0.25 
	End If
	If LutSet = 15 Then
		Playsound "gun", 0, 1, 0.1, 0.25 
	End If
	LutSlctr.enabled = False
end sub


'kickers/saucers
Sub sw67_Hit:Controller.Switch(55)=1:End Sub
Sub HandleTrough(Enabled)
	If Enabled Then
	Controller.Switch(55)=0
	bsTrough.AddBall 0
	sw67.Destroyball
	End If
End Sub

'drop targets
Sub sw00_Hit:dtGreen.Hit 1:End Sub
Sub sw10_Hit:dtGreen.Hit 2:End Sub
Sub sw20_Hit:dtGreen.Hit 3:End Sub

Sub sw03_Hit:dtYellow.Hit 1:End Sub
Sub sw13_Hit:dtYellow.Hit 2:End Sub
Sub sw23_Hit:dtYellow.Hit 3:End Sub

Sub sw02_Hit:dtBlue.Hit 1:End Sub
Sub sw12_Hit:dtBlue.Hit 2:End Sub
Sub sw22_Hit:dtBlue.Hit 3:End Sub

Sub sw01_Hit:dtRed.Hit 1:End Sub
Sub sw11_Hit:dtRed.Hit 2:End Sub
Sub sw21_Hit:dtRed.Hit 3:End Sub

Sub sw04_Hit:dtWhite.Hit 1:End Sub
Sub sw14_Hit:dtWhite.Hit 2:End Sub
Sub sw24_Hit:dtWhite.Hit 3:End Sub

Sub Kicker2_Hit:Controller.Switch(53)=1:End Sub

'spot targets
Sub sw25a_Hit:VpmTimer.PulseSw 25:DOF 113, DOFPulse:End Sub ' #1 spot target
Sub sw25b_Hit:VpmTimer.PulseSw 25:DOF 113, DOFPulse:End Sub ' #3 spot target
Sub sw15a_Hit:VpmTimer.PulseSw 15:DOF 114, DOFPulse:End Sub ' lower rightspot target
Sub sw15b_Hit:VpmTimer.PulseSw 15:DOF 113, DOFPulse:End Sub ' #2 spot target
Sub sw06_Hit:VpmTimer.PulseSw 6:End Sub ' captive ball spot target

'rollovers/rollunders
Sub sw26_Hit:Controller.Switch(26)=1:End Sub
Sub sw26_UnHit:Controller.Switch(26)=0:End Sub
Sub sw50_Hit:Controller.Switch(50)=1:End Sub
Sub sw50_UnHit:Controller.Switch(50)=0:End Sub
Sub sw51_Hit:Controller.Switch(51)=1:End Sub
Sub sw51_UnHit:Controller.Switch(51)=0:End Sub

'Bumpers/Slingshots
Sub Bumper1_Hit:VpmTimer.PulseSw 52:playsoundAtVol SoundFX("fx2_bumper1",DOFContactors), bumper1, VolBump: DOF 101, DOFPulse:End Sub
Sub Bumper2_Hit:VpmTimer.PulseSw 52:playsoundAtVol SoundFX("fx2_bumper2",DOFContactors), bumper2, VolBump: DOF 102, DOFPulse:End Sub
Sub Bumper3_Hit:VpmTimer.PulseSw 52:playsoundAtVol SoundFX("fx2_bumper1",DOFContactors), bumper3, VolBump: DOF 103, DOFPulse:End Sub
Sub Bumper4_Hit:VpmTimer.PulseSw 52:playsoundAtVol SoundFX("fx2_bumper2",DOFContactors), bumper4, VolBump: DOF 104, DOFPulse:End Sub
Sub Bumper5_Hit:VpmTimer.PulseSw 52:playsoundAtVol SoundFX("fx2_bumper1",DOFContactors), bumper5, VolBump: DOF 105, DOFPulse:End Sub
Sub Bumper6_Hit:VpmTimer.PulseSw 52:playsoundAtVol SoundFX("fx2_bumper2",DOFContactors), bumper6, VolBump: DOF 106, DOFPulse:End Sub
Sub Bumper7_Hit:VpmTimer.PulseSw 52:playsoundAtVol SoundFX("fx2_bumper1",DOFContactors), bumper7, VolBump: DOF 107, DOFPulse:End Sub

'**********Sling Shot Animations

dim ULAstep, ULBstep, UCDropStep, LRLTopStep, LRRTopStep, LSlingLstep, LSlingRstep, LLstep, LRstep, CLtopstep, CLdropstep, CLstep, CRstep, CDropStep, Ustep, UCStep, UCTopstep, URstep, ULstep

Sub URubberWall_hit
	'PlaySound SoundFX("")
    URubber_.Visible = 0
    URubber_1.Visible = 1
    UStep = 0
    URubberWall.TimerEnabled = 1
End Sub

Sub URubberWall_Timer
    Select Case UStep
        Case 3:URubber_1.Visible = 0:URubber_2.Visible = 1:URubber_.Visible = 0
        Case 4:URubber_.Visible = 1:URubber_2.Visible = 0:URubber_1.Visible = 0:URubberWall.TimerEnabled = 0
    End Select
    UStep = UStep + 1
End Sub

Sub ULDropAWall_hit
	'PlaySound SoundFX("")
    ULDropA_.Visible = 0
    ULDropA_1.Visible = 1
    ULAStep = 0
    ULDropAWall.TimerEnabled = 1
End Sub

Sub ULDropAWall_Timer
    Select Case ULAStep
        Case 3:ULDropA_1.Visible = 0:ULDropA_2.Visible = 1:ULDropA_.Visible = 0
        Case 4:ULDropA_.Visible = 1:ULDropA_2.Visible = 0:ULDropA_1.Visible = 0:ULDropAWall.TimerEnabled = 0
    End Select
    ULAStep = ULAStep + 1
End Sub

Sub ULDropBWall_hit
	'PlaySound SoundFX("")
    ULDropB_.Visible = 0
    ULDropB_1.Visible = 1
    ULBStep = 0
    ULDropBWall.TimerEnabled = 1
End Sub

Sub ULDropBWall_Timer
    Select Case ULBStep
        Case 3:ULDropB_1.Visible = 0:ULDropB_2.Visible = 1:ULDropB_.Visible = 0
        Case 4:ULDropB_.Visible = 1:ULDropB_2.Visible = 0:ULDropB_1.Visible = 0:ULDropBWall.TimerEnabled = 0
    End Select
    ULAStep = ULAStep + 1
End Sub

Sub UCSlingWall_slingshot
    PlaySoundAt SoundFX("fx2_slingshot1",DOFContactors), UCSLING
	VpmTimer.PulseSw 16:DOF 110, DOFPulse
    UCRubber_.Visible = 0
    UCRubber_1.Visible = 1
    UCSLING.TransZ = -25
    UCStep = 0
    UCSlingWall.TimerEnabled = 1
End Sub

Sub UCSlingWall_Timer
    Select Case UCStep
        Case 3:UCRubber_1.Visible = 0:UCRubber_2.Visible = 1:UCSLING.TransZ = -14:UCRubber_.Visible = 0
        Case 4:UCSLING.TransZ = 0:UCRubber_.Visible = 0:UCRubber_2.Visible = 0:UCRubber_3.Visible = 1
		Case 5:UCRubber_3.Visible = 0:UCRubber_.Visible = 1:UCSlingWall.TimerEnabled = 0
    End Select
    UCStep = UCStep + 1
End Sub

Sub ULRubberWall_hit
	'PlaySound SoundFX("")
    ULRubber_.Visible = 0
    ULRubber_1.Visible = 1
    ULStep = 0
    ULRubberWall.TimerEnabled = 1
End Sub

Sub ULRubberWall_Timer
    Select Case ULStep
        Case 3:ULRubber_1.Visible = 0:ULRubber_2.Visible = 1:ULRubber_.Visible = 0
        Case 4:ULRubber_.Visible = 1:ULRubber_2.Visible = 0:ULRubber_1.Visible = 0:ULRubberWall.TimerEnabled = 0
    End Select
    ULStep = ULStep + 1
End Sub

Sub CLRubberTopWall_hit
	'PlaySound SoundFX("")
    CLRubber_.Visible = 0
    CLRubberTop_1.Visible = 1
    CLTopStep = 0
    CLRubberTopWall.TimerEnabled = 1
End Sub

Sub CLRubberTopWall_Timer
    Select Case CLTopStep
        Case 3:CLRubberTop_1.Visible = 0:CLRubberTop_2.Visible = 1:CLRubber_.Visible = 0
        Case 4:CLRubber_.Visible = 1:CLRubberTop_2.Visible = 0:CLRubberTop_1.Visible = 0:CLRubberTopWall.TimerEnabled = 0
    End Select
    CLTopStep = CLTopStep + 1
End Sub

Sub CLRubberDropWall_hit
	'PlaySound SoundFX("")
    CLRubber_.Visible = 0
    CLRubberDrop_1.Visible = 1
    CLDropStep = 0
    CLRubberDropWall.TimerEnabled = 1
End Sub

Sub CLRubberDropWall_Timer
    Select Case CLDropStep
        Case 3:CLRubberDrop_1.Visible = 0:CLRubberDrop_2.Visible = 1:CLRubber_.Visible = 0
        Case 4:CLRubber_.Visible = 1:CLRubberDrop_2.Visible = 0:CLRubberDrop_1.Visible = 0:CLRubberDropWall.TimerEnabled = 0
    End Select
    CLDropStep = CLDropStep + 1
End Sub

Sub CSlingWallL_slingshot
    PlaySoundAt SoundFX("fx2_slingshot2",DOFContactors), CSlingL
	VpmTimer.PulseSw 16:DOF 112, DOFPulse
    CRubberL_.Visible = 0
    CRubberL_1.Visible = 1
    CSLINGL.TransZ = -20
    CLStep = 0
    CSlingWallL.TimerEnabled = 1
End Sub

Sub CSlingWallL_Timer
    Select Case CLStep
        Case 3:CRubberL_1.Visible = 0:CRubberL_2.Visible = 1:CSLINGL.TransZ = -12:CRubberL_.Visible = 0
        Case 4:CSLINGL.TransZ = 0:CRubberL_.Visible = 0:CRubberL_2.Visible = 0:CRubberL_3.Visible = 1
		Case 5:CRubberL_3.Visible = 0:CRubberL_4.Visible = 1:CRubberL_.Visible = 0
		Case 6:CRubberL_4.Visible = 0:CRubberL_.Visible = 1:CSlingWallL.TimerEnabled = 0
    End Select
    CLStep = CLStep + 1
End Sub

Sub CSlingWallR_slingshot
    PlaySoundAt SoundFX("fx2_slingshot1",DOFContactors), CSlingR
	VpmTimer.PulseSw 16:DOF 112, DOFPulse
    CRubberL_.Visible = 0
    CRubberR_1.Visible = 1
    CSLINGR.TransZ = -20
    CRStep = 0
    CSlingWallR.TimerEnabled = 1
End Sub

Sub CSlingWallR_Timer
    Select Case CRStep
        Case 3:CRubberR_1.Visible = 0:CRubberR_2.Visible = 1:CSLINGR.TransZ = -12:CRubberL_.Visible = 0
        Case 4:CSLINGR.TransZ = 0:CRubberL_.Visible = 0:CRubberR_2.Visible = 0:CRubberR_3.Visible = 1
		Case 5:CRubberR_3.Visible = 0:CRubberR_4.Visible = 1:CRubberL_.Visible = 0
		Case 6:CRubberR_4.Visible = 0:CRubberL_.Visible = 1:CSlingWallR.TimerEnabled = 0
    End Select
    CRStep = CRStep + 1
End Sub

Sub LRubberLSlingWall_slingshot
    PlaySoundAt SoundFX("fx2_slingshot2",DOFContactors), LSlingL
	VpmTimer.PulseSw 16:DOF 108, DOFPulse
    LRubberL_.Visible = 0
    LRubberL_1.Visible = 1
    LSLINGL.TransZ = -24
    LSlingLStep = 0
    LRubberLSlingWall.TimerEnabled = 1
End Sub

Sub LRubberLSlingWall_Timer
    Select Case LSlingLStep
        Case 3:LRubberL_1.Visible = 0:LRubberL_2.Visible = 1:LSLINGL.TransZ = -12:LRubberL_.Visible = 0
        Case 4:LSLINGL.TransZ = 0:LRubberL_.Visible = 0:LRubberL_2.Visible = 0:LRubberL_3.Visible = 1
		Case 5:LRubberL_3.Visible = 0:LRubberL_.Visible = 1:LRubberLSlingWall.TimerEnabled = 0
    End Select
    LSlingLStep = LSlingLStep + 1
End Sub

Sub LRubberRSlingWall_slingshot
    PlaySoundAt SoundFX("fx2_slingshot1",DOFContactors), LSlingR
	VpmTimer.PulseSw 16:DOF 109, DOFPulse
    LRubberR_.Visible = 0
    LRubberR_1.Visible = 1
    LSLINGR.TransZ = -19
    LSlingRStep = 0
    LRubberRSlingWall.TimerEnabled = 1
End Sub

Sub LRubberRSlingWall_Timer
    Select Case LSlingRStep
        Case 3:LRubberR_1.Visible = 0:LRubberR_2.Visible = 1:LSLINGR.TransZ = -8:LRubberR_.Visible = 0
        Case 4:LSLINGR.TransZ = 0:LRubberR_.Visible = 0:LRubberR_2.Visible = 0:LRubberR_3.Visible = 1
		Case 5:LRubberR_3.Visible = 0:LRubberR_.Visible = 1:LRubberRSlingWall.TimerEnabled = 0
    End Select
    LSlingRStep = LSlingRStep + 1
End Sub

Sub LRRubberWall_hit
	'PlaySound SoundFX("")
    LRRubber_.Visible = 0
    LRRubber_1.Visible = 1
    LRStep = 0
    LRRubberWall.TimerEnabled = 1
End Sub

Sub LRRubberWall_Timer
    Select Case LRStep
        Case 3:LRRubber_1.Visible = 0:LRRubber_2.Visible = 1:LRRubber_.Visible = 0
        Case 4:LRRubber_.Visible = 1:LRRubber_2.Visible = 0:LRRubber_1.Visible = 0:LRRubberWall.TimerEnabled = 0
    End Select
    LRStep = LRStep + 1
End Sub

Set Lights(3)=L3
Set Lights(12)=L12
Set Lights(13)=L13
Set Lights(14)=L14
Lights(15)=Array(l15,l15bumper)
Set Lights(16)=L16
Set Lights(17)=L17
Set Lights(18)=L18
Lights(19)=Array(l19,l19bumper,l19bumpera)
Set Lights(20)=L20
Set Lights(21)=L21
Set Lights(22)=L22
Set Lights(23)=L23
Lights(24)=Array(L24,l24bumper)
Set Lights(25)=L25
Set Lights(26)=L26
Set Lights(27)=L27
Set Lights(28)=L28
Set Lights(29)=L29
Lights(30)=Array(L30,l30bumper)
Set Lights(31)=L31
Set Lights(32)=L32
Set Lights(33)=L33
Set Lights(34)=L34
Set Lights(35)=L35
Set Lights(36)=L36
Set Lights(37)=L37
Set Lights(38)=L38
Set Lights(39)=L39
Lights(40)=Array(L40,l40bumper)
Set Lights(41)=L41
Lights(42)=Array(l42,l42bumper)

' *******************************************************************************************************
' Positional Sound Playback Functions by DJRobX
' PlaySound sound, 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 0, 1, AudioFade(ActiveBall)
' *******************************************************************************************************

' Play a sound, depending on the X,Y position of the table element (especially cool for surround speaker setups, otherwise stereo panning only)
' parameters (defaults): loopcount (1), volume (1), randompitch (0), pitch (0), useexisting (0), restart (1))
' Note that this will not work (currently) for walls/slingshots as these do not feature a simple, single X,Y position

Sub PlayXYSound(soundname, tableobj, loopcount, volume, randompitch, pitch, useexisting, restart)
  PlaySound soundname, loopcount, volume, AudioPan(tableobj), randompitch, pitch, useexisting, restart, AudioFade(tableobj)
End Sub

' Set position as table object (Use object or light but NOT wall) and Vol to 1

Sub PlaySoundAt(soundname, tableobj)
  PlaySound soundname, 1, 1, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub

'Set all as per ball position & speed.

Sub PlaySoundAtBall(soundname)
  PlaySoundAt soundname, ActiveBall
End Sub

'Set position as table object and Vol manually.

Sub PlaySoundAtVol(sound, tableobj, Vol)
  PlaySound sound, 1, Vol, Pan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub

'Set all as per ball position & speed, but Vol Multiplier may be used eg; PlaySoundAtBallVol "sound",3

Sub PlaySoundAtBallVol(sound, VolMult)
  PlaySound sound, 0, Vol(ActiveBall) * VolMult, Pan(ActiveBall), 0, Pitch(ActiveBall), 0, 1, AudioFade(ActiveBall)
End Sub

'Set position as bumperX and Vol manually.

Sub PlaySoundAtBumperVol(sound, tableobj, Vol)
  PlaySound sound, 1, Vol, Pan(tableobj), 0,0,1, 1, AudioFade(tableobj)
End Sub

'*********************************************************************
'                     Supporting Ball & Sound Functions
'*********************************************************************

Function AudioFade(tableobj) ' Fades between front and back of the table (for surround systems or 2x2 speakers, etc), depending on the Y position on the table. "table1" is the name of the table
  Dim tmp
  tmp = tableobj.y * 2 / table1.height-1
  If tmp > 0 Then
    AudioFade = Csng(tmp ^10)
  Else
    AudioFade = Csng(-((- tmp) ^10) )
  End If
End Function

Function AudioPan(tableobj) ' Calculates the pan for a tableobj based on the X position on the table. "table1" is the name of the table
  Dim tmp
  tmp = tableobj.x * 2 / table1.width-1
  If tmp > 0 Then
    AudioPan = Csng(tmp ^10)
  Else
    AudioPan = Csng(-((- tmp) ^10) )
  End If
End Function

Function Pan(ball) ' Calculates the pan for a ball based on the X position on the table. "table1" is the name of the table
    Dim tmp
    tmp = ball.x * 2 / table1.width-1
    If tmp > 0 Then
        Pan = Csng(tmp ^10)
    Else
        Pan = Csng(-((- tmp) ^10) )
    End If
End Function

Function AudioFade(ball) ' Can this be together with the above function ?
  Dim tmp
  tmp = ball.y * 2 / Table1.height-1
  If tmp > 0 Then
    AudioFade = Csng(tmp ^10)
  Else
    AudioFade = Csng(-((- tmp) ^10) )
  End If
End Function

Function Vol(ball) ' Calculates the Volume of the sound based on the ball speed
  Vol = Csng(BallVel(ball) ^2 / VolDiv)
End Function

Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
  Pitch = BallVel(ball) * 20
End Function

Function BallVel(ball) 'Calculates the ball speed
  BallVel = INT(SQR((ball.VelX ^2) + (ball.VelY ^2) ) )
End Function


'*****************************************
'      JP's VP10 Rolling Sounds
'*****************************************

Const tnob = 5 ' total number of balls
ReDim rolling(tnob)
InitRolling

Sub InitRolling
    Dim i
    For i = 0 to tnob
        rolling(i) = False
    Next
End Sub

Sub RollingTimer_Timer()
    Dim BOT, b
    BOT = GetBalls

	' stop the sound of deleted balls
    For b = UBound(BOT) + 1 to tnob
        rolling(b) = False
        StopSound("fx_ballrolling" & b)
    Next

	' exit the sub if no balls on the table

    For b = 0 to UBound(BOT)
      If BallVel(BOT(b) ) > 1 Then
        rolling(b) = True
        if BOT(b).z < 30 Then ' Ball on playfield
          PlaySound("fx_ballrolling" & b), -1, Vol(BOT(b) ), Pan(BOT(b) ), 0, Pitch(BOT(b) ), 1, 0, AudioFade(BOT(b) )
        Else ' Ball on raised ramp
          PlaySound("fx_ballrolling" & b), -1, Vol(BOT(b) )*.5, Pan(BOT(b) ), 0, Pitch(BOT(b) )+50000, 1, 0, AudioFade(BOT(b) )
        End If
      Else
        If rolling(b) = True Then
          StopSound("fx_ballrolling" & b)
          rolling(b) = False
        End If
      End If
    Next
End Sub

'**********************
' Ball Collision Sound
'**********************

Sub OnBallBallCollision(ball1, ball2, velocity)
    PlaySound("fx_collide"), 0, Csng(velocity) ^2 / (VolDiv/VolCol), Pan(ball1), 0, Pitch(ball1), 0, 0, AudioFade(ball1)
End Sub

'******************************
' Diverse Collection Hit Sounds
'******************************

'Sub aBumpers_Hit (idx): PlaySound SoundFX("fx_bumper", DOFContactors), 0, 1, pan(ActiveBall): End Sub
Sub aRollovers_Hit(idx):PlaySound "fx_sensor", 0, Vol(ActiveBall)*VolRol, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aGates_Hit(idx):PlaySound "fx_Gate", 0, Vol(ActiveBall)*VolGates, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aMetals_Hit(idx):PlaySound "fx_MetalHit2", 0, Vol(ActiveBall)*VolMetal, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aRubber_Bands_Hit(idx):PlaySound "fx_rubber", 0, Vol(ActiveBall)*VolRB, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aRubbers_Hit(idx):PlaySound "fx_postrubber", 0, Vol(ActiveBall)*VolRH, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aRubber_Posts_Hit(idx):PlaySound "fx2_rubber_hit_2", 0, Vol(ActiveBall)*VolPo, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aRubber_Pins_Hit(idx):PlaySound "fx2_pinhit", 0, Vol(ActiveBall)*VolPi, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aPlastics_Hit(idx):PlaySound "fx_PlasticHit", 0, Vol(ActiveBall)*VolPlast, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aTargets_Hit(idx):PlaySound "fx2_target", 0, Vol(ActiveBall)*VolTarg, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aWoods_Hit(idx):PlaySound "fx_Woodhit", 0, Vol(ActiveBall)*VolWood, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub

'*****************************************
'	ninuzzu's	BALL SHADOW
'*****************************************
Dim BallShadow
BallShadow = Array (BallShadow1,BallShadow2,BallShadow3,BallShadow4,BallShadow5)


Sub BallShadowUpdate_timer()
    Dim BOT, b
    BOT = GetBalls
    ' hide shadow of deleted balls
    If UBound(BOT)<(tnob-1) Then
        For b = (UBound(BOT) + 1) to (tnob-1)
            BallShadow(b).visible = 0
        Next
    End If
    ' exit the Sub if no balls on the table
    If UBound(BOT) = -1 Then Exit Sub
    ' render the shadow for each ball
    For b = 0 to UBound(BOT)
        If BOT(b).X < Table1.Width/2 Then
            BallShadow(b).X = ((BOT(b).X) - (Ballsize/6) + ((BOT(b).X - (Table1.Width/2))/7)) + 6
        Else
            BallShadow(b).X = ((BOT(b).X) + (Ballsize/6) + ((BOT(b).X - (Table1.Width/2))/7)) - 6
        End If
        ballShadow(b).Y = BOT(b).Y + 12
        If BOT(b).Z > 20 Then
            BallShadow(b).visible = 1
        Else
            BallShadow(b).visible = 0
        End If
    Next
End Sub

'Gottlieb Goin Nuts
'added by Inkochnito
Sub editDips
	Dim vpmDips:Set vpmDips=New cvpmDips
	With vpmDips
		.AddForm 700,400,"Goin' Nuts - DIP switches"
		.AddFrame 2,2,190,"Maximum credits",49152,Array("8 credits",0,"10 credits",32768,"15 credits",&H00004000,"20 credits",49152)'dip 15&16
		.AddFrame 2,80,190,"Coin chute 1 and 2 control",&H00002000,Array("seperate",0,"same",&H00002000)'dip 14
		.AddFrame 2,126,190,"Playfield special",&H00200000,Array("replay",0,"extra ball",&H00200000)'dip 22
		.AddFrame 2,172,190,"Game mode",&H10000000,Array("replay",0,"extra ball",&H10000000)'dip 29
		.AddFrame 2,218,190,"Award for sequence completion",&H80000000,Array("extra ball",0,"special",&H40000000)'dip 32
		.AddFrame 205,2,190,"High score to date awards",&H00C00000,Array("not displayed and no award",0,"displayed and no award",&H00800000,"displayed and 2 replays",&H00400000,"displayed and 3 replays",&H00C00000)'dip 23&24
		.AddFrame 205,80,190,"Balls per game",&H01000000,Array("5 balls",0,"3 balls",&H01000000)'dip 25
		.AddFrame 205,126,190,"Replay limit",&H04000000,Array("no limit",0,"one per ball",&H04000000)'dip 27
		.AddFrame 205,172,190,"Novelty mode",&H08000000,Array("normal game mode",0,"50K per special/extra ball",&H08000000)'dip 28
		.AddFrame 205,218,190,"3rd coin chute credits control",&H20000000,Array("no effect",0,"add 9",&H20000000)'dip 30
		.AddFrameExtra 205,264,190,"SS-dip 3&&4 Attract Sound",&H000C,Array("off",0,"every 10 seconds",&H0004,"every 2 minutes",&H0008,"every 4 minutes",&H000C)'SS-board dip 3&4
		.AddChk 2,273,190,Array("Match feature",&H02000000)'dip 26
		.AddChkExtra 2,288,190,Array("SS-dip 5 Background sound",&H0010)'SS-board dip 5
		.AddChkExtra 2,303,190,Array("SS-dip 6 Speech",&H0020)'SS-board dip 6
		.AddChkExtra 2,318,190,Array("SS-dip 7 Extra sound option",&H0040)'SS-board dip 7
		.AddLabel 50,340,300,20,"After hitting OK, press F3 to reset game with new settings."
	End With
	Dim extra
	extra=Controller.Dip(4)+Controller.Dip(5)*256
	extra=vpmDips.ViewDipsExtra(extra)
	Controller.Dip(4)=extra And 255
	Controller.Dip(5)=(extra And 65280)\256 And 255
End Sub
Set vpmShowDips=GetRef("editDips")

'******************************************************
'		FLIPPER CORRECTION INITIALIZATION
'******************************************************

dim LF : Set LF = New FlipperPolarity
dim RF : Set RF = New FlipperPolarity

InitPolarity

Sub InitPolarity()
	dim x, a : a = Array(LF, RF)
	for each x in a
		x.AddPoint "Ycoef", 0, RightFlipper.Y-65, 1	'disabled
		x.AddPoint "Ycoef", 1, RightFlipper.Y-11, 1
		x.enabled = True
		x.TimeDelay = 80
	Next

	AddPt "Polarity", 0, 0, 0
	AddPt "Polarity", 1, 0.05, -2.7	
	AddPt "Polarity", 2, 0.33, -2.7
	AddPt "Polarity", 3, 0.37, -2.7	
	AddPt "Polarity", 4, 0.41, -2.7
	AddPt "Polarity", 5, 0.45, -2.7
	AddPt "Polarity", 6, 0.576,-2.7
	AddPt "Polarity", 7, 0.66, -1.8
	AddPt "Polarity", 8, 0.743, -0.5
	AddPt "Polarity", 9, 0.81, -0.5
	AddPt "Polarity", 10, 0.88, 0

	addpt "Velocity", 0, 0, 	1
	addpt "Velocity", 1, 0.16, 1.06
	addpt "Velocity", 2, 0.41, 	1.05
	addpt "Velocity", 3, 0.53, 	1'0.982
	addpt "Velocity", 4, 0.702, 0.968
	addpt "Velocity", 5, 0.95,  0.968
	addpt "Velocity", 6, 1.03, 	0.945

	LF.Object = LeftFlipper	
	LF.EndPoint = EndPointLp
	RF.Object = RightFlipper
	RF.EndPoint = EndPointRp
End Sub

Sub TriggerLF_Hit() : LF.Addball activeball : End Sub
Sub TriggerLF_UnHit() : LF.PolarityCorrect activeball : End Sub
Sub TriggerRF_Hit() : RF.Addball activeball : End Sub
Sub TriggerRF_UnHit() : RF.PolarityCorrect activeball : End Sub

'******************************************************
'			FLIPPER CORRECTION FUNCTIONS
'******************************************************

Sub AddPt(aStr, idx, aX, aY)	'debugger wrapper for adjusting flipper script in-game
	dim a : a = Array(LF, RF)
	dim x : for each x in a
		x.addpoint aStr, idx, aX, aY
	Next
End Sub

Class FlipperPolarity
	Public DebugOn, Enabled
	Private FlipAt	'Timer variable (IE 'flip at 723,530ms...)
	Public TimeDelay	'delay before trigger turns off and polarity is disabled TODO set time!
	private Flipper, FlipperStart,FlipperEnd, FlipperEndY, LR, PartialFlipCoef
	Private Balls(20), balldata(20)
	
	dim PolarityIn, PolarityOut
	dim VelocityIn, VelocityOut
	dim YcoefIn, YcoefOut
	Public Sub Class_Initialize 
		redim PolarityIn(0) : redim PolarityOut(0) : redim VelocityIn(0) : redim VelocityOut(0) : redim YcoefIn(0) : redim YcoefOut(0)
		Enabled = True : TimeDelay = 50 : LR = 1:  dim x : for x = 0 to uBound(balls) : balls(x) = Empty : set Balldata(x) = new SpoofBall : next 
	End Sub
	
	Public Property let Object(aInput) : Set Flipper = aInput : StartPoint = Flipper.x : End Property
	Public Property Let StartPoint(aInput) : if IsObject(aInput) then FlipperStart = aInput.x else FlipperStart = aInput : end if : End Property
	Public Property Get StartPoint : StartPoint = FlipperStart : End Property
	Public Property Let EndPoint(aInput) : FlipperEnd = aInput.x: FlipperEndY = aInput.y: End Property
	Public Property Get EndPoint : EndPoint = FlipperEnd : End Property	
	Public Property Get EndPointY: EndPointY = FlipperEndY : End Property
	
	Public Sub AddPoint(aChooseArray, aIDX, aX, aY) 'Index #, X position, (in) y Position (out) 
		Select Case aChooseArray
			case "Polarity" : ShuffleArrays PolarityIn, PolarityOut, 1 : PolarityIn(aIDX) = aX : PolarityOut(aIDX) = aY : ShuffleArrays PolarityIn, PolarityOut, 0
			Case "Velocity" : ShuffleArrays VelocityIn, VelocityOut, 1 :VelocityIn(aIDX) = aX : VelocityOut(aIDX) = aY : ShuffleArrays VelocityIn, VelocityOut, 0
			Case "Ycoef" : ShuffleArrays YcoefIn, YcoefOut, 1 :YcoefIn(aIDX) = aX : YcoefOut(aIDX) = aY : ShuffleArrays YcoefIn, YcoefOut, 0
		End Select
		if gametime > 100 then Report aChooseArray
	End Sub 

	Public Sub Report(aChooseArray) 	'debug, reports all coords in tbPL.text
		if not DebugOn then exit sub
		dim a1, a2 : Select Case aChooseArray
			case "Polarity" : a1 = PolarityIn : a2 = PolarityOut
			Case "Velocity" : a1 = VelocityIn : a2 = VelocityOut
			Case "Ycoef" : a1 = YcoefIn : a2 = YcoefOut 
			case else :tbpl.text = "wrong string" : exit sub
		End Select
		dim str, x : for x = 0 to uBound(a1) : str = str & aChooseArray & " x: " & round(a1(x),4) & ", " & round(a2(x),4) & vbnewline : next
		tbpl.text = str
	End Sub
	
	Public Sub AddBall(aBall) : dim x : for x = 0 to uBound(balls) : if IsEmpty(balls(x)) then set balls(x) = aBall : exit sub :end if : Next  : End Sub

	Private Sub RemoveBall(aBall)
		dim x : for x = 0 to uBound(balls)
			if TypeName(balls(x) ) = "IBall" then 
				if aBall.ID = Balls(x).ID Then
					balls(x) = Empty
					Balldata(x).Reset
				End If
			End If
		Next
	End Sub
	
	Public Sub Fire() 
		Flipper.RotateToEnd
		processballs
	End Sub

	Public Property Get Pos 'returns % position a ball. For debug stuff.
		dim x : for x = 0 to uBound(balls)
			if not IsEmpty(balls(x) ) then
				pos = pSlope(Balls(x).x, FlipperStart, 0, FlipperEnd, 1)
			End If
		Next		
	End Property

	Public Sub ProcessBalls() 'save data of balls in flipper range
		FlipAt = GameTime
		dim x : for x = 0 to uBound(balls)
			if not IsEmpty(balls(x) ) then
				balldata(x).Data = balls(x)
			End If
		Next
		PartialFlipCoef = ((Flipper.StartAngle - Flipper.CurrentAngle) / (Flipper.StartAngle - Flipper.EndAngle))
		PartialFlipCoef = abs(PartialFlipCoef-1)
	End Sub
	Private Function FlipperOn() : if gameTime < FlipAt+TimeDelay then FlipperOn = True : End If : End Function	'Timer shutoff for polaritycorrect
	
	Public Sub PolarityCorrect(aBall)
		if FlipperOn() then 
			dim tmp, BallPos, x, IDX, Ycoef : Ycoef = 1

			'y safety Exit
			if aBall.VelY > -8 then 'ball going down
				RemoveBall aBall
				exit Sub
			end if

			'Find balldata. BallPos = % on Flipper
			for x = 0 to uBound(Balls)
				if aBall.id = BallData(x).id AND not isempty(BallData(x).id) then 
					idx = x
					BallPos = PSlope(BallData(x).x, FlipperStart, 0, FlipperEnd, 1)
					if ballpos > 0.65 then  Ycoef = LinearEnvelope(BallData(x).Y, YcoefIn, YcoefOut)				'find safety coefficient 'ycoef' data
				end if
			Next

			If BallPos = 0 Then 'no ball data meaning the ball is entering and exiting pretty close to the same position, use current values.
				BallPos = PSlope(aBall.x, FlipperStart, 0, FlipperEnd, 1)
				if ballpos > 0.65 then  Ycoef = LinearEnvelope(aBall.Y, YcoefIn, YcoefOut)						'find safety coefficient 'ycoef' data
			End If

			'Velocity correction
			if not IsEmpty(VelocityIn(0) ) then
				Dim VelCoef
	 : 			VelCoef = LinearEnvelope(BallPos, VelocityIn, VelocityOut)

				if partialflipcoef < 1 then VelCoef = PSlope(partialflipcoef, 0, 1, 1, VelCoef)

				if Enabled then aBall.Velx = aBall.Velx*VelCoef
				if Enabled then aBall.Vely = aBall.Vely*VelCoef
			End If

			'Polarity Correction (optional now)
			if not IsEmpty(PolarityIn(0) ) then
				If StartPoint > EndPoint then LR = -1	'Reverse polarity if left flipper
				dim AddX : AddX = LinearEnvelope(BallPos, PolarityIn, PolarityOut) * LR
	
				if Enabled then aBall.VelX = aBall.VelX + 1 * (AddX*ycoef*PartialFlipcoef)
				'playsound "knocker"
			End If
		End If
		RemoveBall aBall
	End Sub
End Class

'******************************************************
'		RUBBER POST AND SLEEVE DAMPENERS
'******************************************************
'These are data mined bounce curves, 
'dialed in with the in-game elasticity as much as possible to prevent angle / spin issues.

Sub dPosts_Hit(idx) 
	RubbersD.dampen Activeball
End Sub

Sub dSleeves_Hit(idx) 
	SleevesD.Dampen Activeball
End Sub

dim RubbersD : Set RubbersD = new Dampener	'frubber
RubbersD.name = "Rubbers"

'cor bounce curve (linear)
'for best results, try to match in-game velocity as closely as possible to the desired curve
'RubbersD.addpoint 0, 0, 0.935	'point# (keep sequential), ballspeed, CoR (elasticity)
RubbersD.addpoint 0, 0, 1.11	'point# (keep sequential), ballspeed, CoR (elasticity)
RubbersD.addpoint 1, 3.77, 0.96
RubbersD.addpoint 2, 5.76, 0.967	'dont take this as gospel. if you can data mine rubber elasticitiy, please help!
RubbersD.addpoint 3, 15.84, 0.874
RubbersD.addpoint 4, 56, 0.64	'there's clamping so interpolate up to 56 at least

dim SleevesD : Set SleevesD = new Dampener	'this is just rubber but cut down to 85%...
SleevesD.name = "Sleeves"
SleevesD.CopyCoef RubbersD, 0.85

Class Dampener
	public name, Threshold 	'Minimum threshold. Useful for Flippers, which don't have a hit threshold.
	Public ModIn, ModOut
	Private Sub Class_Initialize : redim ModIn(0) : redim Modout(0): End Sub 

	Public Sub AddPoint(aIdx, aX, aY) 
		ShuffleArrays ModIn, ModOut, 1 : ModIn(aIDX) = aX : ModOut(aIDX) = aY : ShuffleArrays ModIn, ModOut, 0
	End Sub

	public sub Dampen(aBall)
		if threshold then if BallSpeed(aBall) < threshold then exit sub end if end if
		dim RealCOR, DesiredCOR, str, coef
		DesiredCor = LinearEnvelope(cor.ballvel(aBall.id), ModIn, ModOut )
		RealCOR = BallSpeed(aBall) / cor.ballvel(aBall.id)
		coef = desiredcor / realcor 
		
		aBall.velx = aBall.velx * coef : aBall.vely = aBall.vely * coef
	End Sub

	Public Sub CopyCoef(aObj, aCoef) 'alternative addpoints, copy with coef
		dim x : for x = 0 to uBound(aObj.ModIn)
			addpoint x, aObj.ModIn(x), aObj.ModOut(x)*aCoef
		Next
	End Sub

End Class

'******************************************************
'		TRACK ALL BALL VELOCITIES
' 		FOR RUBBER DAMPENER AND DROP TARGETS
'******************************************************

dim cor : set cor = New CoRTracker

Class CoRTracker
	public ballvel, ballvelx, ballvely

	Private Sub Class_Initialize : redim ballvel(0) : redim ballvelx(0): redim ballvely(0) : End Sub 

	Public Sub Update()	'tracks in-ball-velocity
		dim str, b, AllBalls, highestID : allBalls = getballs

		for each b in allballs
			if b.id >= HighestID then highestID = b.id
		Next

		if uBound(ballvel) < highestID then redim ballvel(highestID)	'set bounds
		if uBound(ballvelx) < highestID then redim ballvelx(highestID)	'set bounds
		if uBound(ballvely) < highestID then redim ballvely(highestID)	'set bounds

		for each b in allballs
			ballvel(b.id) = BallSpeed(b)
			ballvelx(b.id) = b.velx
			ballvely(b.id) = b.vely
		Next
	End Sub
End Class

Sub RDampen_Timer()
	Cor.Update
End Sub

'******************************************************
'		FLIPPER POLARITY, DAMPENER, AND DROP TARGET
'				SUPPORTING FUNCTIONS 
'******************************************************

' Used for flipper correction and rubber dampeners
Sub ShuffleArray(ByRef aArray, byVal offset) 'shuffle 1d array
	dim x, aCount : aCount = 0
	redim a(uBound(aArray) )
	for x = 0 to uBound(aArray)	'Shuffle objects in a temp array
		if not IsEmpty(aArray(x) ) Then
			if IsObject(aArray(x)) then 
				Set a(aCount) = aArray(x)
			Else
				a(aCount) = aArray(x)
			End If
			aCount = aCount + 1
		End If
	Next
	if offset < 0 then offset = 0
	redim aArray(aCount-1+offset)	'Resize original array
	for x = 0 to aCount-1		'set objects back into original array
		if IsObject(a(x)) then 
			Set aArray(x) = a(x)
		Else
			aArray(x) = a(x)
		End If
	Next
End Sub

' Used for flipper correction and rubber dampeners
Sub ShuffleArrays(aArray1, aArray2, offset)
	ShuffleArray aArray1, offset
	ShuffleArray aArray2, offset
End Sub

' Used for flipper correction, rubber dampeners, and drop targets
Function BallSpeed(ball) 'Calculates the ball speed
    BallSpeed = SQR(ball.VelX^2 + ball.VelY^2 + ball.VelZ^2)
End Function

' Used for flipper correction and rubber dampeners
Function PSlope(Input, X1, Y1, X2, Y2)	'Set up line via two points, no clamping. Input X, output Y
	dim x, y, b, m : x = input : m = (Y2 - Y1) / (X2 - X1) : b = Y2 - m*X2
	Y = M*x+b
	PSlope = Y
End Function

' Used for flipper correction
Class spoofball 
	Public X, Y, Z, VelX, VelY, VelZ, ID, Mass, Radius 
	Public Property Let Data(aBall)
		With aBall
			x = .x : y = .y : z = .z : velx = .velx : vely = .vely : velz = .velz
			id = .ID : mass = .mass : radius = .radius
		end with
	End Property
	Public Sub Reset()
		x = Empty : y = Empty : z = Empty  : velx = Empty : vely = Empty : velz = Empty 
		id = Empty : mass = Empty : radius = Empty
	End Sub
End Class

' Used for flipper correction and rubber dampeners
Function LinearEnvelope(xInput, xKeyFrame, yLvl)
	dim y 'Y output
	dim L 'Line
	dim ii : for ii = 1 to uBound(xKeyFrame)	'find active line
		if xInput <= xKeyFrame(ii) then L = ii : exit for : end if
	Next
	if xInput > xKeyFrame(uBound(xKeyFrame) ) then L = uBound(xKeyFrame)	'catch line overrun
	Y = pSlope(xInput, xKeyFrame(L-1), yLvl(L-1), xKeyFrame(L), yLvl(L) )

	if xInput <= xKeyFrame(lBound(xKeyFrame) ) then Y = yLvl(lBound(xKeyFrame) ) 	'Clamp lower
	if xInput >= xKeyFrame(uBound(xKeyFrame) ) then Y = yLvl(uBound(xKeyFrame) )	'Clamp upper

	LinearEnvelope = Y
End Function

' Used for drop targets
Function Atn2(dy, dx)
	dim pi
	pi = 4*Atn(1)

	If dx > 0 Then
		Atn2 = Atn(dy / dx)
	ElseIf dx < 0 Then
		If dy = 0 Then 
			Atn2 = pi
		Else
			Atn2 = Sgn(dy) * (pi - Atn(Abs(dy / dx)))
		end if
	ElseIf dx = 0 Then
		if dy = 0 Then
			Atn2 = 0
		else
			Atn2 = Sgn(dy) * pi / 2
		end if
	End If
End Function

' Used for drop targets
'*** Determines if a Points (px,py) is inside a 4 point polygon A-D in Clockwise/CCW order
Function InRect(px,py,ax,ay,bx,by,cx,cy,dx,dy)
	Dim AB, BC, CD, DA
	AB = (bx*py) - (by*px) - (ax*py) + (ay*px) + (ax*by) - (ay*bx)
	BC = (cx*py) - (cy*px) - (bx*py) + (by*px) + (bx*cy) - (by*cx)
	CD = (dx*py) - (dy*px) - (cx*py) + (cy*px) + (cx*dy) - (cy*dx)
	DA = (ax*py) - (ay*px) - (dx*py) + (dy*px) + (dx*ay) - (dy*ax)
 
	If (AB <= 0 AND BC <=0 AND CD <= 0 AND DA <= 0) Or (AB >= 0 AND BC >=0 AND CD >= 0 AND DA >= 0) Then
		InRect = True
	Else
		InRect = False       
	End If
End Function

' Used for drop targets
Function Distance(ax,ay,bx,by)
	Distance = SQR((ax - bx)^2 + (ay - by)^2)
End Function

Sub Table1_exit()
	Controller.Pause = False
	SaveLUT:Controller.Stop
End Sub

'***************** 
' CODE BELOW IS FOR THE VR CLOCK.  This was originally taken from Rascal VP9 clock table 
'*****************

Dim CurrentMinute ' for VR clock

Sub ClockTimer_Timer()

    'ClockHands Below *********************************************************
	VR_ClockMinutes.RotAndTra2 = (Minute(Now())+(Second(Now())/100))*6
	VR_ClockHours.RotAndTra2 = Hour(Now())*30+(Minute(Now())/2)
    VR_ClockSeconds.RotAndTra2 = (Second(Now()))*6
	CurrentMinute=Minute(Now())

End Sub

'******************************
' Setup Backglass
'******************************

Dim xoff,yoff1, yoff2, yoff3, yoff4, yoff5, yoff6, zoff,xrot,zscale, xcen,ycen

Sub setup_backglass()

	xoff = -20
	yoff1 = 64 ' this is where you adjust the forward/backward position for player 1 score
	yoff2 = 64 ' this is where you adjust the forward/backward position for player 2 score
	yoff3 = 58 ' this is where you adjust the forward/backward position for player 3 score
	yoff4 = 58 ' this is where you adjust the forward/backward position for player 4 score
	yoff5 = 58 ' this is where you adjust the forward/backward position for credits and ball in play
	yoff6 = 64 ' this is where you adjust the forward/backward position for single ball timer
	zoff = 699
	xrot = -90

	center_digits()

end sub

Sub center_digits()
	Dim ix, xx, yy, yfact, xfact, xobj

	zscale = 0.0000001

	xcen = (130 /2) - (92 / 2)
	ycen = (780 /2 ) + (203 /2)

	for ix = 0 to 6
		For Each xobj In Digits(ix)

			xx = xobj.x  
				
			xobj.x = (xoff - xcen) + xx
			yy = xobj.y ' get the yoffset before it is changed
			xobj.y = yoff1 

			If (yy < 0.) then
				yy = yy * -1
			end if

			xobj.height = (zoff - ycen) + yy - (yy * (zscale))
			xobj.rotx = xrot
		Next
	Next

	for ix = 7 to 13
		For Each xobj In Digits(ix)

			xx = xobj.x  
				
			xobj.x = (xoff - xcen) + xx
			yy = xobj.y ' get the yoffset before it is changed
			xobj.y = yoff2 

			If (yy < 0.) then
				yy = yy * -1
			end if

			xobj.height = (zoff - ycen) + yy - (yy * (zscale))
			xobj.rotx = xrot
		Next
	Next

	for ix = 14 to 20
		For Each xobj In Digits(ix)

			xx = xobj.x  
				
			xobj.x = (xoff - xcen) + xx
			yy = xobj.y ' get the yoffset before it is changed
			xobj.y = yoff3 

			If (yy < 0.) then
				yy = yy * -1
			end if

			xobj.height = (zoff - ycen) + yy - (yy * (zscale))
			xobj.rotx = xrot
		Next
	Next

	for ix = 21 to 27
		For Each xobj In Digits(ix)

			xx = xobj.x  
				
			xobj.x = (xoff - xcen) + xx
			yy = xobj.y ' get the yoffset before it is changed
			xobj.y = yoff4 

			If (yy < 0.) then
				yy = yy * -1
			end if

			xobj.height = (zoff - ycen) + yy - (yy * (zscale))
			xobj.rotx = xrot
		Next
	Next

	for ix = 28 to 31
		For Each xobj In Digits(ix)

			xx = xobj.x  
				
			xobj.x = (xoff - xcen) + xx
			yy = xobj.y ' get the yoffset before it is changed
			xobj.y = yoff5 

			If (yy < 0.) then
				yy = yy * -1
			end if

			xobj.height = (zoff - ycen) + yy - (yy * (zscale))
			xobj.rotx = xrot
		Next
	Next

	for ix = 32 to 34
		For Each xobj In Digits(ix)

			xx = xobj.x  
				
			xobj.x = (xoff - xcen) + xx
			yy = xobj.y ' get the yoffset before it is changed
			xobj.y = yoff6 

			If (yy < 0.) then
				yy = yy * -1
			end if

			xobj.height = (zoff - ycen) + yy - (yy * (zscale))
			xobj.rotx = xrot
		Next
	Next

end sub

Dim Digits(35)
Digits(0) = Array(LED1x0,LED1x1,LED1x2,LED1x3,LED1x4,LED1x5,LED1x6,led1x7,led1x8)
Digits(1) = Array(LED2x0,LED2x1,LED2x2,LED2x3,LED2x4,LED2x5,LED2x6,led2x7,led2x8)
Digits(2) = Array(LED3x0,LED3x1,LED3x2,LED3x3,LED3x4,LED3x5,LED3x6,led3x7,led3x8)
Digits(3) = Array(LED4x0,LED4x1,LED4x2,LED4x3,LED4x4,LED4x5,LED4x6,led4x7,led4x8)
Digits(4) = Array(LED5x0,LED5x1,LED5x2,LED5x3,LED5x4,LED5x5,LED5x6,led5x7,led5x8)
Digits(5) = Array(LED6x0,LED6x1,LED6x2,LED6x3,LED6x4,LED6x5,LED6x6,led6x7,led6x8)
Digits(6) = Array(LED7x0,LED7x1,LED7x2,LED7x3,LED7x4,LED7x5,LED7x6,led7x7,led7x8)

Digits(7) = Array(LED8x0,LED8x1,LED8x2,LED8x3,LED8x4,LED8x5,LED8x6,led8x7,led8x8)
Digits(8) = Array(LED9x0,LED9x1,LED9x2,LED9x3,LED9x4,LED9x5,LED9x6,led9x7,led9x8)
Digits(9) = Array(LED10x0,LED10x1,LED10x2,LED10x3,LED10x4,LED10x5,LED10x6,led10x7,led10x8)
Digits(10) = Array(LED11x0,LED11x1,LED11x2,LED11x3,LED11x4,LED11x5,LED11x6,led11x7,led11x8)
Digits(11) = Array(LED12x0,LED12x1,LED12x2,LED12x3,LED12x4,LED12x5,LED12x6,led12x7,led12x8)
Digits(12) = Array(LED13x0,LED13x1,LED13x2,LED13x3,LED13x4,LED13x5,LED13x6,led13x7,led13x8)
Digits(13) = Array(LED14x0,LED14x1,LED14x2,LED14x3,LED14x4,LED14x5,LED14x6,led14x7,led14x8)

Digits(14) = Array(LED1x000,LED1x001,LED1x002,LED1x003,LED1x004,LED1x005,LED1x006,LED1x007,LED1x008)
Digits(15) = Array(LED1x100,LED1x101,LED1x102,LED1x103,LED1x104,LED1x105,LED1x106,LED1x107,LED1x108)
Digits(16) = Array(LED1x200,LED1x201,LED1x202,LED1x203,LED1x204,LED1x205,LED1x206,LED1x207,LED1x208)
Digits(17) = Array(LED1x300,LED1x301,LED1x302,LED1x303,LED1x304,LED1x305,LED1x306,LED1x307,LED1x308)
Digits(18) = Array(LED1x400,LED1x401,LED1x402,LED1x403,LED1x404,LED1x405,LED1x406,LED1x407,LED1x408)
Digits(19) = Array(LED1x500,LED1x501,LED1x502,LED1x503,LED1x504,LED1x505,LED1x506,LED1x507,LED1x508)
Digits(20) = Array(LED1x600,LED1x601,LED1x602,LED1x603,LED1x604,LED1x605,LED1x606,LED1x607,LED1x608)

Digits(21) = Array(LED2x000,LED2x001,LED2x002,LED2x003,LED2x004,LED2x005,LED2x006,led2x007,led2x008)
Digits(22) = Array(LED2x100,LED2x101,LED2x102,LED2x103,LED2x104,LED2x105,LED2x106,led2x107,led2x108)
Digits(23) = Array(LED2x200,LED2x201,LED2x202,LED2x203,LED2x204,LED2x205,LED2x206,led2x207,led2x208)
Digits(24) = Array(LED2x300,LED2x301,LED2x302,LED2x303,LED2x304,LED2x305,LED2x306,led2x307,led2x308)
Digits(25) = Array(LED2x400,LED2x401,LED2x402,LED2x403,LED2x404,LED2x405,LED2x406,led2x407,led2x408)
Digits(26) = Array(LED2x500,LED2x501,LED2x502,LED2x503,LED2x504,LED2x505,LED2x506,led2x507,led2x508)
Digits(27) = Array(LED2x600,LED2x601,LED2x602,LED2x603,LED2x604,LED2x605,LED2x606,led2x607,led2x608)

'credit -- Ball In Play
Digits(28) = Array(LEDax300,LEDax301,LEDax302,LEDax303,LEDax304,LEDax305,LEDax306)
Digits(29) = Array(LEDbx400,LEDbx401,LEDbx402,LEDbx403,LEDbx404,LEDbx405,LEDbx406)
Digits(30) = Array(LEDcx500,LEDcx501,LEDcx502,LEDcx503,LEDcx504,LEDcx505,LEDcx506)
Digits(31) = Array(LEDdx600,LEDdx601,LEDdx602,LEDdx603,LEDdx604,LEDdx605,LEDdx606)

'single ball timer
Digits(32) = Array(LED3x000,LED3x001,LED3x002,LED3x003,LED3x004,LED3x005,LED3x006,LED3x007,LED3x008)
Digits(33) = Array(LED3x100,LED3x101,LED3x102,LED3x103,LED3x104,LED3x105,LED3x106,LED3x107,LED3x108)
Digits(34) = Array(LED3x200,LED3x201,LED3x202,LED3x203,LED3x204,LED3x205,LED3x206,LED3x207,LED3x208)



dim DisplayColor
DisplayColor =  RGB(20,180,0)

Sub DisplayTimer
    Dim ChgLED, ii, jj, num, chg, stat, obj, b, x
    ChgLED=Controller.ChangedLEDs(&Hffffffff, &Hffffffff)
    If Not IsEmpty(ChgLED)Then
       For ii=0 To UBound(chgLED)
          num=chgLED(ii, 0) : chg=chgLED(ii, 1) : stat=chgLED(ii, 2)
			If num <35 Then
              For Each obj In Digits(num)
'                   If chg And 1 Then obj.visible=stat And 1    'if you use the object color for off; turn the display object visible to not visible on the playfield, and uncomment this line out.
				   If chg And 1 Then FadeDisplay obj, stat And 1	
                   chg=chg\2 : stat=stat\2
              Next
			End If
        Next
    End If

 End Sub

Sub FadeDisplay(object, onoff)
	If OnOff = 1 Then
		object.color = DisplayColor
		Object.Opacity = 12
	Else
		Object.Color = RGB(1,1,1)
		Object.Opacity = 6
	End If
End Sub


Sub InitDigits()
	dim tmp, x, obj
	for x = 0 to uBound(Digits)
		if IsArray(Digits(x) ) then
			For each obj in Digits(x)
				obj.height = obj.height + 18
				FadeDisplay obj, 0
			next
		end If
	Next
End Sub

InitDigits


' #####  COMMENTS  #####
' This the section to add if you have lamps called out on the backglass  
' ######################

' ******************************************************************************************
'      LAMP CALLBACK for the backglass flasher lamps (not the solenoid conrolled ones)
' ******************************************************************************************


Set LampCallback = GetRef("UpdateMultipleLamps")

dim CZ,NewCZ,DTZ,NewDTZ,BZ,NewBZ
CZ=0
DTZ=0
BZ=0

Sub UpdateMultipleLamps
	NewCZ=L12.State
	If NewCZ<>CZ Then
			If L12.State=1 And bsTrough.Balls>0 Then bsTrough.ExitSol_On
	End If
	CZ=NewCZ
	NewDTZ=L13.State
	If NewDTZ<>DTZ Then
			If L13.State=1 Then dtWhite.DropSol_On
	End If
	DTZ=NewDTZ
	NewBZ=L14.State
	If NewBZ<>BZ Then
			Controller.Switch(53)=0
			Kicker2.Kick 0,38
	End If
	BZ=NewBZ

	IF VRRoom = 1 Or VRRoom = 2  Then
		If Controller.Lamp(1) = 0 Then: f_Tilt.visible=0: else: f_Tilt.visible=1	'Tilt
		If Controller.Lamp(3) = 0 Then: f_SA.visible=0: else: f_SA.visible=1	'Shoot Again
		If Controller.Lamp(10) = 0 Then	f_HS.visible=0: else: f_HS.visible=1	'Highscore
		If Controller.Lamp(11) = 0 Then: f_GO.visible=0: else: f_GO.visible=1	'Game Over
	End If

End Sub

'******************************************************
' 					LUT
'******************************************************

Sub SetLUT
	Table1.ColorGradeImage = "LUT" & LUTset
end sub 

Sub LUTBox_Timer
	LUTBox.TimerEnabled = 0 
	LUTBox.Visible = 0
	LUTBack.visible = 0
	VRLutdesc.visible = 0
End Sub

Sub ShowLUT
	LUTBox.visible = 1
	LUTBack.visible = 1
	VRLutdesc.visible = 1

	Select Case LUTSet
        Case 0: LUTBox.text = "Fleep Natural Dark 1": VRLUTdesc.imageA = "LUTcase0"
		Case 1: LUTBox.text = "Fleep Natural Dark 2": VRLUTdesc.imageA = "LUTcase1"
		Case 2: LUTBox.text = "Fleep Warm Dark": VRLUTdesc.imageA = "LUTcase2"
		Case 3: LUTBox.text = "Fleep Warm Bright": VRLUTdesc.imageA = "LUTcase3"
		Case 4: LUTBox.text = "Fleep Warm Vivid Soft": VRLUTdesc.imageA = "LUTcase4"
		Case 5: LUTBox.text = "Fleep Warm Vivid Hard": VRLUTdesc.imageA = "LUTcase5"
		Case 6: LUTBox.text = "Skitso Natural and Balanced": VRLUTdesc.imageA = "LUTcase6"
		Case 7: LUTBox.text = "Skitso Natural High Contrast": VRLUTdesc.imageA = "LUTcase7"
		Case 8: LUTBox.text = "3rdaxis Referenced THX Standard": VRLUTdesc.imageA = "LUTcase8"
		Case 9: LUTBox.text = "CalleV Punchy Brightness and Contrast": VRLUTdesc.imageA = "LUTcase9"
		Case 10: LUTBox.text = "HauntFreaks Desaturated" : VRLUTdesc.imageA = "LUTcase10"
  		Case 11: LUTBox.text = "Tomate washed out": VRLUTdesc.imageA = "LUTcase11"
		Case 12: LUTBox.text = "VPW original 1on1": VRLUTdesc.imageA = "LUTcase12"
		Case 13: LUTBox.text = "bassgeige": VRLUTdesc.imageA = "LUTcase13"
		Case 14: LUTBox.text = "blacklight": VRLUTdesc.imageA = "LUTcase14"
		Case 15: LUTBox.text = "B&W Comic Book": VRLUTdesc.imageA = "LUTcase15"
	End Select

	LUTBox.TimerEnabled = 1

End Sub

Sub SaveLUT

	Dim FileObj
	Dim ScoreFile

	Set FileObj=CreateObject("Scripting.FileSystemObject")
	If Not FileObj.FolderExists(UserDirectory) then 
		Exit Sub
	End if

	if LUTset = "" then LUTset = 12 'failsafe

	Set ScoreFile=FileObj.CreateTextFile(UserDirectory & "GNLUT.txt",True)
	ScoreFile.WriteLine LUTset
	Set ScoreFile=Nothing
	Set FileObj=Nothing

End Sub

Sub LoadLUT

	Dim FileObj, ScoreFile, TextStr
	dim rLine

	Set FileObj=CreateObject("Scripting.FileSystemObject")
	If Not FileObj.FolderExists(UserDirectory) then 
		LUTset=12
		Exit Sub
	End if
	If Not FileObj.FileExists(UserDirectory & "GNLUT.txt") then
		LUTset=12
		Exit Sub
	End if
	Set ScoreFile=FileObj.GetFile(UserDirectory & "GNLUT.txt")
	Set TextStr=ScoreFile.OpenAsTextStream(1,0)
		If (TextStr.AtEndOfStream=True) then
			Exit Sub
		End if
		rLine = TextStr.ReadLine
		If rLine = "" then
			LUTset=12
			Exit Sub
		End if
		LUTset = int (rLine) 
		Set ScoreFile = Nothing
	    Set FileObj = Nothing
End Sub