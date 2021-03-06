//Landing script
clearscreen.
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
lock steering to lookdirup(srfretrograde:vector, up:topvector).
set vmin to vminfield:text:tonumber(). //minimum landing speed
set vmax to vmaxfield:text:tonumber(). //maximum landing speed
set f to maxthrust.
set h to ship:bounds:size:mag. //conservative ship height
set g0 to body:mu/body:radius^2. //gravitational acceleration
lock g1 to f/mass * cos(vang(up:vector, srfretrograde:vector)*0.9). //vertical acceleration without gravity
print "Coast".

wait until 0.9*g1 > g0. //Avoid math errors
lock vs to -1*verticalspeed. //ships vertical speed
lock vv to sqrt(2*(alt:radar-h)*(0.9*g1-g0)). //target vertical speed
wait until 0.9 + 0.1*(vs-vv)/(vmax-vmin) > 0. //wait until its time to throttle up
set thr to 1.
lock throttle to thr.
print "Suizide burn".

until vs < vmax { //suizide burn control
	if md = 0 { //bang-bang control
		if vs > vv set thr to 1.
		else set thr to 0.
	}
	if md = 1 set thr to max(min(0.9 + 0.1*(vs-vv)/(vmax-vmin), 1), 0.01). //Throttle control
}

print "Touchdown".
until vs < 0.1 { //touchdown speed control
	if md = 0 {
		if vs > vmax set thr to 1.
		if vs < vmin set thr to 0.
	}
	if md = 1 set thr to max(min(2*g0*mass*(vs-vmin)/f/(vmax-vmin), 1), 0.01).
}

lock throttle to 0.
print "Autolanding completed".

function printmode {
	if md = 0 print "Mode = Bang-Bang".
	if md = 1 print "Mode = Throttle".
}