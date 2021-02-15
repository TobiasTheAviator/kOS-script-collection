clearscreen.
set gui to gui(150).
set as to gui:addbutton("autostage").
set ldg to gui:addbutton("landing").
set ldg2 to gui:addbutton("landing2").
set nd to gui:addbutton("ndexe").
set sl to gui:addbutton("simplelaunch").
set f to gui:addbutton("FINISH").
gui:show().
when as:takepress then ld("0:/autostage").
when ldg:takepress then ld("0:/ldg").
when ldg2:takepress then ld("0:/ldg2").
when nd:takepress then ld("0:/ndexe").
when sl:takepress then ld("0:/simplelaunch").
wait until f:takepress.
print "Startup completed".
clearguis().

function ld {
	parameter path.
	copypath(path,"").
	print path+" loaded, "+core:volume:freespace+"b left".
}.
