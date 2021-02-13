//Active Powered Ascent Guidance
clearscreen.
parameter t0 is 0, t1 is 10. //terminal guidance time
set gui to gui(128).
set pelabel to gui:addlabel("Periapsis [km]").
set pefield to gui:addtextfield("200").
set aplabel to gui:addlabel("Apoapsis [km]").
set apfield to gui:addtextfield("200").
set hdglabel to gui:addlabel("Heading [°]").
set hdgfield to gui:addtextfield("90").
set vgtlabel to gui:addlabel("GT velocity [m/s]").
set vgtfield to gui:addtextfield("50").
set exe to gui:addbutton("EXECUTE").
gui:show().

print "EXECUTE: launch".
wait until exe:takepress.

SAS off.
set pe to 1000*pefield:text:tonumber(). //periapsis
set ap to 1000*apfield:text:tonumber(). //apoapsis
set hdg to hdgfield:text:tonumber(). //heading
set vgt to vgtfield:text:tonumber(). //velocity to start gravity turn
set vht to sqrt(body:mu*(2/(body:radius+pe) - 2/(2*body:radius+pe+ap))). //horizontal velocity to reach target orbit
lock throttle to 1. //full thrust with g-limitation

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
lock ptc to 90-vang(up:vector, srfprograde:vector). //pitch angle
wait until ptc < 85. //until pitch <= 85°
lock steering to heading(hdg, ptc, 0). //minimizing drag loss
print "Prograde ascent".
print "EXECUTE: active guidance".
wait until exe:takepress.
clearguis().

//active guidance
print "Active guidance".
set fref to maxthrust. //reference thrust
list engines in englist.
set mf to 0. //mass flow
for eng in englist set mf to mf + eng:maxmassflow. //mass flow
set ce to fref/mf. //effective exhaust velocity
set mref to mass. //reference mass
set caot to cos(ptc/2). //first guess
lock vh to vxcl(up:vector, velocity:orbit):mag. //current horizontal velocity
lock dvh to vht - vh. //required horizontal delta v to reach target orbit
guidance(). //first guidance iteration
lock ptc to aot + a0 + a1*mass. //pitch program
until tb+tref-time:seconds < t1 if time:seconds-tref > 2 guidance(). //update control loop every two seconds
guidance(). //terminal guidance
print "Terminal Guidance".
wait until dvh <= 0.05*fref/mref. //prevent overshooting
lock throttle to 0. //engine cutoff
print "Guidance finished".
SAS on.

//function block, ordered alphabetic
function guidance { //guidance algorithm
	set ce to fref/mf. //effective exhaust velocity
	set tb to mass/mf*(1-constant:e^(-dvh/ce/caot)). //estimated burn time
	set aot to (tb*body:mu)/(body:radius+pe)^2 - verticalspeed - vh2dt(0,tb)/(body:radius+pe).
	set aot to arctan(aot/dvh). //medium aot
	set caot to cos(aot).
	set a0 to pe - altitude - verticalspeed*tb - ce*tb*sin(aot) + body:mu*tb^2/2/(body:radius+pe)^2.
	set a0 to a0 - dvh*tan(aot)*(tb-mass/mf) - vh2dt2(tb)/(body:radius+pe).
	set a0 to a0 / (tb*dvh/2 + ce*tb*caot - mass*dvh/mf) * constant:radtodeg.
	if tb < t0 set a0 to 0. //constant thrust angle
	set a1 to -a0*dvh/(mf*tb*ce*caot).
	set tref to time:seconds. //new reference time
	set mref to mass. //new reference mass
	print "DeltaV: " + round(dvh/ca) + "m/s  " at(0,7).
	print "Time  : " + round(tb) + "s  " at(0,8).
	print "Pitch : " + round(aot+a0+a1*mass,1) + "°  " at(0,9).
}

function vh2 { //approx. squared horizontal velocity
	parameter t.
	return (vh + ce*caot*ln(mass/(mass-mf*t)))^2.
}

function vh2dt { //gauss integration of vh^2(t)
	parameter t0, t1.
	local r1 to 5/9*vh2(t0+0.113*(t1-t0)).
	set r1 to r1 + 8/9*vh2(0.5*(t1+t0)).
	set r1 to r1 + 5/9*vh2(t0+0.887*(t1-t0)).
	return r1*(t1-t0)/2.
}

function vh2dt2 { //twice gauss integration of vh^2(t)
	parameter t.
	local r2 to 2*vh2dt(0, 0.113*t).
	set r2 to r2 + 13/9*vh2dt(0.113*t, 0.5*t).
	set r2 to r2 + 5/9*vh2dt(0.5*t, 0.887*t).
	return r2*t/2.
}