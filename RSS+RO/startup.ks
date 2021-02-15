clearscreen.
set gui to gui(128).
set apag to gui:addbutton("apag").
set as to gui:addbutton("autostage").
set ldg to gui:addbutton("landing").
set ldg2 to gui:addbutton("landing2").
set nd to gui:addbutton("ndexe").
set sbg to gui:addbutton("sbg").
set f to gui:addbutton("FINISH").
gui:show().
when apag:takepress then ld("0:/apag").
when as:takepress then ld("0:/autostage").
when ldg:takepress then ld("0:/ldg").
when ldg2:takepress then ld("0:/ldg2").
when nd:takepress then ld("0:/ndexe").
when sbg:takepress then ld("0:/sbg").
wait until f:takepress.
print "Startup completed".
clearguis().

function ld {
	parameter path.
	copypath(path,"").
	print path+" loaded, "+core:volume:freespace+"b left".
}.
