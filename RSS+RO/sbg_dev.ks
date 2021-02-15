//Simple Ballistic Guidance
clearscreen.
set gui to gui(128).
set ptclabel to gui:addlabel("Target Pitch [°]").
set ptcfield to gui:addtextfield("45").
set hdglabel to gui:addlabel("Heading [°]").
set hdgfield to gui:addtextfield("90").
set vgtlabel to gui:addlabel("GT velocity [m/s]").
set vgtfield to gui:addtextfield("50").
set exe to gui:addbutton("START").
set fin to gui:addbutton("EXIT").
gui:show().
print "Press START to launch".
set mode to 0. //exit mode
lock throttle to 1.
wait until exe:takepress.

SAS off.
set tptc to ptcfield:text:tonumber(). //target pitch
set hdg to hdgfield:text:tonumber(). //heading
set vgt to vgtfield:text:tonumber(). //velocity to start gravity turn

//autostage
when stage:deltav:vacuum = 0 and stage:ready then {
	if mode = 0 stage.
	if mode = 1 set mode to 2.
	return true.
}

//guidance.
lock steering to heading(hdg, 90, 0).
print "Vertical ascent".
wait until verticalspeed >= vgt.
print "Gravity turn".
lock steering to heading(hdg, 85, 0). //start gravity turn
lock ptc to 90 - vang(up:vector, srfprograde:vector). //pitch angle
wait until ptc <= 85. //until pitch <= 85°
lock steering to heading(hdg, ptc, 0). //minimizing drag loss
print "Prograde ascent".
print "Press EXIT to exit at next staging".
when ptc <= tptc then { //when pitch is target pitch
	lock ptc to tptc. //hold pitch
	print "Pitch hold".
}
when fin:takepress then { //exit armed
	set mode to 1. //stop staging
	print "Exiting at next staging".
	print "Press EXIT to exit now".
}
wait until mode = 2 or (fin:takepress and mode = 1). //exit
print "Guidance exited".
SAS on.
clearguis().