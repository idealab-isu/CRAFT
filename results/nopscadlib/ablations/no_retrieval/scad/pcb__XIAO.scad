// PCB: 21.0mm x 18.0mm x 1.2mm
// One connected solid (board outline only)

$fn = 64;

pcb_L = 21.0;
pcb_W = 18.0;
pcb_T = 1.2;

color([0.0, 0.4, 0.2])
translate([0, 0, pcb_T/2])   // place on Z=0 plane for reliable viewing
    cube([pcb_L, pcb_W, pcb_T], center=true);