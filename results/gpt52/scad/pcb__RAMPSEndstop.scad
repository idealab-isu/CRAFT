$fn=64;

module pcb(length=40.0, width=16.0, thickness=1.6) {
    translate([0,0,thickness/2])
        cube([length, width, thickness], center=true);
}

pcb();