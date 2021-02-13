clearscreen.
set gui to gui(200).
set v0l to gui:addlabel("Min Ldg Speed [m/s]").
set v0f to gui:addtextfield("1").
set v1l to gui:addlabel("Max Ldg Speed [m/s]").
set v1f to gui:addtextfield("2").
set ms to gui:addbutton("Switch Landing Mode").
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
lock steering to lookdirup(srfretrograde,facing:topvector).
print "Coast".
wait until .9*g1>g0.
set v0 to v0f:text:tonumber().
set v1 to v1f:text:tonumber().
set f to maxthrust.
set h to ship:bounds:size:mag.
set g0 to body:mu/body:radius^2.
lock g1 to f/mass*cos(vang(up:vector,facing:vector)*.9).
lock vs to -1*verticalspeed.
lock vv to sqrt(2*(alt:radar-h)*(.9*g1-g0)).
wait until .9+.1*(vs-vv)/(v1-v0)>0.
set t to 1.
lock throttle to t.
print "Suizide burn".
until vs<v1 {
if m=0 {
if vs>vv set t to 1.
else set t to 0.}
if m=1 set t to max(min(.9+.1*(vs-vv)/(v1-v0),1),.01).}
print "Touchdown".
until vs<=0 {
if m=0 {
if vs>v1 set t to 1.
if vs<v0 set t to 0.}
if m=1 set t to max(min(2*g0*mass*(vs-v0)/f/(v1-v0),1),.01).}
lock throttle to 0.
print "Autolanding completed".
function pm {
if m=0 print "Mode = Bang-Bang".
if m=1 print "Mode = Throttle".}
