//node execution
clearscreen.
parameter tu is 5.
SAS off.
set nd to nextnode.
set mt to maxthrust.
lock steering to nd:deltav.
lock throttle to 0.

list engines in englist. //engine list
set ff to 0. //fuel flow
for eng in englist if eng:ignition set ff to ff + eng:maxmassflow. //sum over all engines
set ce to mt/ff. //effective exhaust velocity
set tb to mass/ff*(1-constant:e^(-0.5*nd:deltav:mag/ce)). //time to node at burn start
print("Orientating").

//execution
wait until nd:eta <= tb + tu.
print("Ullaging").
RCS on.
set ship:control:fore to 1.
wait until nd:eta <= tb.
print("Executing").
lock throttle to 1. //engine ignition
set ship:control:neutralize to true. //stop ullaging
lock tb to nd:deltav:mag*mass/mt. //simplyfied remaining burn time
wait until tb <= 0.1. //final execution
set dir to facing.
lock steering to dir.
wait tb*0.5.
lock throttle to 0. //cutoff engine
print("Completed").
SAS on.