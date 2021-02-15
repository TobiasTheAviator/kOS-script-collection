clearscreen.
parameter t0 is 0, t1 is 10.
set gi to gui(128).
set pl to gi:addlabel("Periapsis [km]").
set pf to gi:addtextfield("200").
set al to gi:addlabel("Apoapsis [km]").
set af to gi:addtextfield("200").
set hl to gi:addlabel("Heading [°]").
set hf to gi:addtextfield("90").
set vl to gi:addlabel("GT velocity [m/s]").
set vf to gi:addtextfield("50").
set exe to gi:addbutton("EXECUTE").
gi:show().
print "EXECUTE: launch".
wait until exe:takepress.
SAS off.
set pe to 1000*pf:text:tonumber().
set ap to 1000*af:text:tonumber().
set h to hf:text:tonumber().
set vg to vf:text:tonumber().
set vt to sqrt(body:mu*(2/(body:radius+pe) - 2/(2*body:radius+pe+ap))).
lock throttle to 1.
when stage:deltav:vacuum=0 and stage:ready then {
stage.
return true.}
lock steering to heading(h,90,0).
print "Vertical ascent".
wait until verticalspeed>=vg.
print "Gravity turn".
lock steering to heading(h,85,0).
lock p to 90-vang(up:vector,srfprograde:vector).
wait until p<85.
lock steering to heading(h,p,0).
print "Prograde ascent".
print "EXECUTE: active guidance".
wait until exe:takepress.
clearguis().
print "Active guidance".
set fr to maxthrust.
list engines in el.
set mf to 0.
for eng in el if eng:ignition and not eng:flameout set mf to mf+eng:maxmassflow.
set ce to fr/mf.
set mr to mass.
set ca to cos(p/2).
lock vh to vxcl(up:vector,velocity:orbit):mag.
lock dvh to vt-vh.
gd(). gd().
lock p to aot+a0+a1*mass.
until tb+tr-time:seconds<t1 if time:seconds-tr>2 gd().
gd().
print "Terminal guidance".
wait until dvh<=.05*fr/mr.
lock throttle to 0.
print "Completed".
SAS on.
function gd {
set fr to .9*fr+.1*maxthrust.
if mr>mass+mf set mf to .9*mf+.1*(mr-mass)/(time:seconds-tr).
set ce to fr/mf.
set tb to mass/mf*(1-constant:e^(-dvh/ce/ca)).
set aot to (tb*body:mu)/(body:radius+pe)^2-verticalspeed-vh2t(0,tb)/(body:radius+pe).
set aot to arctan(aot/dvh).
set ca to cos(aot).
set a0 to pe-altitude-verticalspeed*tb-ce*tb*sin(aot)+body:mu*tb^2/2/(body:radius+pe)^2.
set a0 to a0-dvh*tan(aot)*(tb-mass/mf)-vh2t2(tb)/(body:radius+pe).
set a0 to a0/(tb*dvh/2+ce*tb*ca-mass*dvh/mf)*constant:radtodeg.
if tb<t0 set a0 to 0.
set a1 to -a0*dvh/(mf*tb*ce*ca).
set tr to time:seconds.
set mr to mass.
print "DeltaV: "+round(dvh/ca)+"m/s  " at(0,7).
print "Time  : "+round(tb)+"s  " at(0,8).
print "Pitch : "+round(aot+a0+a1*mass,1)+"°  " at(0,9).}
function vh2 {
parameter t.
return (vh+ce*ca*ln(mass/(mass-mf*t)))^2.}
function vh2t {
parameter t0, t1.
local r1 is 5/9*vh2(t0+0.113*(t1-t0)).
set r1 to r1+8/9*vh2(0.5*(t1+t0)).
set r1 to r1+5/9*vh2(t0+0.887*(t1-t0)).
return r1*(t1-t0)/2.}
function vh2t2 {
parameter t.
local r2 is 2*vh2t(0, 0.113*t).
set r2 to r2+13/9*vh2t(0.113*t, 0.5*t).
set r2 to r2+5/9*vh2t(0.5*t, 0.887*t).
return r2*t/2.}