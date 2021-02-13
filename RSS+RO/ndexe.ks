clearscreen.
parameter tu is 5.
SAS off.
set nd to nextnode.
set mt to maxthrust.
lock steering to nd:deltav.
lock throttle to 0.
set mt to maxthrust.
list engines in el.
set ff to 0.
for eng in el if eng:ignition set ff to ff+eng:maxmassflow.
set ce to mt/ff.
set tb to mass/ff*(1-constant:e^(-.5*nd:deltav:mag/ce)).
print("Orientating").
wait until nd:eta<=tb+tu.
print("Ullaging").
RCS on.
set ship:control:fore to 1.
wait until nd:eta <= tb.
print("Executing").
lock throttle to 1.
set ship:control:neutralize to true.
lock tb to nd:deltav:mag*mass/mt.
wait until tb<=.1.
set dir to facing.
lock steering to dir.
wait tb*.5.
lock throttle to 0.
print("Completed").
SAS on.