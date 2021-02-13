clearscreen.
set gui to gui(128).
set pl to gui:addlabel("Target Pitch [°]").
set pf to gui:addtextfield("45").
set hl to gui:addlabel("Heading [°]").
set hf to gui:addtextfield("90").
set vl to gui:addlabel("GT velocity [m/s]").
set vf to gui:addtextfield("50").
set s to gui:addbutton("START").
set f to gui:addbutton("EXIT").
gui:show().
print "Press START to launch".
set m to 0.
lock throttle to 1.
wait until s:takepress.
SAS off.
set pt to pf:text:tonumber().
set h to hf:text:tonumber().
set vg to vf:text:tonumber().
when stage:deltav:vacuum=0 and stage:ready then {
if m=0 stage.
if m=1 set m to 2.
return true.}
lock steering to heading(h,90,0).
print "Vertical ascent".
wait until verticalspeed>=vg.
print "Gravity turn".
lock steering to heading(h,85,0).
lock p to 90-vang(up:vector, srfprograde:vector).
wait until p<=85.
lock steering to heading(h,p,0).
print "Prograde ascent".
print "Press EXIT to exit at next staging".
when p <= pt then {
lock p to pt.
print "Pitch hold".}
when f:takepress then {
set m to 1.
print "Exiting at next staging".
print "Press EXIT to exit now".}
wait until m=2 or (f:takepress and m=1).
print "Guidance exited".
SAS on.
clearguis().