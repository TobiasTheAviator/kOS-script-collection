clearscreen.
copypath("0:/ndexe.ks","").
set gui to gui(128).
set pelabel to gui:addlabel("Periapsis [km]").
set pefield to gui:addtextfield("100").
set aplabel to gui:addlabel("Apoapsis [km]").
set apfield to gui:addtextfield("100").
set hdglabel to gui:addlabel("Heading [°]").
set hdgfield to gui:addtextfield("90").
set vlabel to gui:addlabel("GT velocity [m/s]").
set vfield to gui:addtextfield("50").
set exe to gui:addbutton("EXECUTE").
gui:show().
print "Press EXECUTE to launch".
wait until exe:takepress.

//Initialization
SAS off.
set pe to 1000*pefield:text:tonumber(). //periapsis
set ap to 1000*apfield:text:tonumber(). //apoapsis
set hdg to hdgfield:text:tonumber(). //heading
set vgt to vfield:text:tonumber(). //velocity to start gravity turn
lock throttle to 1. //full thrust
set dv to sqrt(body:mu*(2/(body:radius+pe) - 2/(2*body:radius+pe+ap))). //horizontal speed to reach target orbit
clearguis().

//autostage
when stage:deltav:vacuum = 0 and stage:ready then {
	stage.
	return true.
}

//simple pitch program
lock steering to heading(hdg, 90, 0).
print "Vertical ascent".
wait until verticalspeed >= vgt.
print "Gravity turn".
lock steering to heading(hdg, 85, 0). //start gravity turn
lock ptc to 90 - vang(up:vector, srfprograde:vector). //pitch angle
wait until ptc <= 85. //until pitch <= 85°
lock steering to heading(hdg, ptc, 0). //minimizing drag loss
print "Prograde ascent".

//coast phase and apoapsis adjustment
wait until apoapsis >= ap.
lock throttle to 0.
print "Coast through atmosphere".
wait until altitude >= body:atm:height.
lock steering to prograde. 
print "Apoapsis adjustment".
lock throttle to 1. //apoapsis correction
wait until apoapsis >= ap.
lock throttle to 0.
print "Coast to final burn".

//final burn
set dv to dv - velocityat(ship, time:seconds + eta:apoapsis):orbit:mag. //saving one variable
add node(time:seconds + eta:apoapsis, 0, 0, dv).
run ndexe.ks.
clearscreen.
print "Guidance finished".