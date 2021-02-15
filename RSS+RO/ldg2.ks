clearscreen.
parameter s is 1.
set gui to gui(150).
set v0l to gui:addlabel("Min Ldg Speed [m/s]").
set v0f to gui:addtextfield("1").
set v1l to gui:addlabel("Max Ldg Speed [m/s]").
set v1f to gui:addtextfield("2").
set ms to gui:addbutton("Switch Mode").
set exe to gui:addbutton("EXECUTE").
set m to 0.
gui:show().
print "Press EXECUTE to autoland".
pm().
when ms:takepress then {
if m=0 set m to 1.
else if m=1 set m to 0.
pm().
return true.}
wait until exe:takepress.
clearscreen.
print "Autolanding active".
pm().
clearguis().
SAS off.
lock steering to lookdirup(srfretrograde:vector,up:topvector).
set v0 to -1*v0f:text:tonumber().
set v1 to -1*v1f:text:tonumber().
set f to maxthrust.
set h to ship:bounds:size:mag.
lock g0 to -body:mu/body:radius^2.
lock g1 to vxcl(up:vector,velocity:orbit):mag^2/body:radius+g0.
lock vs to verticalspeed.
lock tb to groundspeed*mass/f-vs/(f/mass+g0).
set da to alt:radar-h.
set ti to -.1-(sqrt(vs^2 - 2*g1*dalt)+vs)/g1.
get_ti().
print "Converged".
until ti/tb < 0.8*s get_ti().
set thr to 1.
lock throttle to thr.
print "Suizide burn".
until vs>vmax {
get_ti().
if md=0 {
if ti/tb<0.6*s set thr to 1.
else set thr to 0.}
if md=1 set thr to max(min(3.2-4*ti/tb/s,1),.01).}
print "Touchdown".
until vs >= -.1 {
if md = 0 {
if vs < vmax set thr to 1.
if vs > vmin set thr to 0.}
if md = 1 set thr to max(min(-2*g0*mass*vs/f/(vmax+vmin), 1), 0.01).}
lock throttle to 0.
print "Autolanding completed".
function printmode {
if md = 0 print "Mode = Bang-Bang".
if md = 1 print "Mode = Throttle".}
function get_ti {
local ti_old is ti+1.
until abs(ti_old-ti)<.1 {
set ti_old to ti.
set da to .5*max(da+altitude-h-body:geopositionof(positionat(ship,time:seconds+ti)):terrainheight, 0).
set ti to -.1-(sqrt(vs^2 - 2*g1*dalt)+vs)/g1.}}