//Landing script
clearscreen.
parameter s is 1. //safety factor
set gui to gui(150).
set vminlabel to gui:addlabel("Min Ldg Speed [m/s]").
set vminfield to gui:addtextfield("1").
set vmaxlabel to gui:addlabel("Max Ldg Speed [m/s]").
set vmaxfield to gui:addtextfield("2").
set mdswitch to gui:addbutton("Switch Mode").
set exe to gui:addbutton("EXECUTE").
set md to 0. //landing mode: Bang-Bang or Throttle
gui:show().
print "Press EXECUTE to autoland".
printmode().

when mdswitch:takepress then {
	if md = 0 set md to 1.
	else if md = 1 set md to 0.
	printmode().
	return true.
}

wait until exe:takepress.
clearscreen.
print "Autolanding active".
printmode().
clearguis().
SAS off.
lock steering to lookdirup(srfretrograde:vector, facing:topvector).
set vmin to -1*vminfield:text:tonumber(). //minimum landing speed
set vmax to -1*vmaxfield:text:tonumber(). //maximum landing speed
set f to maxthrust.
set h to ship:bounds:size:mag. //conservative ship height
lock g0 to -body:mu / body:radius^2. //gravitational acceleration
lock g1 to vxcl(up:vector, velocity:orbit):mag^2 / body:radius + g0. //effective centripetal acceleration
lock vs to verticalspeed.
lock tb to groundspeed*mass/f - vs/(f/mass+g0). //burn time, linear addition
set dalt to alt:radar-h. //altitude differnce ship - landing point terrain height, first guess
set ti to -0.1 - (sqrt(vs^2 - 2*g1*dalt)+vs)/g1. //impact UT, first guess
get_ti().
print "Converged".

until ti/tb < 0.8*s get_ti(). //update ti
set thr to 0.
lock throttle to thr.
print "Suizide burn".
until vs > vmax { //suizide burn control
	get_ti().
	if md = 0 {
		if ti/tb < 0.6*s set thr to 1.
		else set thr to 0.
	}
	if md = 1 set thr to max(min(3.2 - 4*ti/tb/s, 1), 0.01).
}

print "Touchdown".
until vs >= -0.1 { //touchdown speed control
	if md = 0 {
		if vs < vmax set thr to 1.
		if vs > vmin set thr to 0.
	}
	if md = 1 set thr to max(min(-2*g0*mass*vs/f/(vmax+vmin), 1), 0.01).
}

lock throttle to 0.
print "Autolanding completed".

function printmode {
	if md = 0 print "Mode = Bang-Bang".
	if md = 1 print "Mode = Throttle".
}

function get_ti {
	local ti_old is ti+1.
	until abs(ti_old-ti) < 0.1 {
		set ti_old to ti.
		set dalt to 0.5*max(dalt + altitude - h - body:geopositionof(positionat(ship, time:seconds+ti)):terrainheight, 0).
		//height between craft and estimated landing point with sea-level limit, relaxation of 0.5
		set ti to -0.1 - (sqrt(vs^2 - 2*g1*dalt)+vs)/g1. //estimated UT impact time, 0.1 s safety
	}
}