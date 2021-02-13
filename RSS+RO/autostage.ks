clearscreen.
set gui to gui(64).
set str to gui:addbutton("START").
set stp to gui:addbutton("STOP").
gui:show().
print "Ready".
wait until str:takepress.
print "Running".
when stage:deltav:vacuum=0 and stage:ready then {
stage.
return true.}
wait until stp:takepress.
clearguis().
print "Stopped".