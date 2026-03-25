$fn=96;

module heatshrink_sleeve(len=50, id=6, wall=1.2, chamfer=1.0) {
    od = id + 2*wall;
    difference() {
        union() {
            cylinder(h=len, d=od, center=true);
            if (chamfer > 0) {
                translate([0,0, len/2])
                    cylinder(h=2*chamfer, d1=od-2*chamfer, d2=od, center=true);
                translate([0,0,-len/2])
                    cylinder(h=2*chamfer, d1=od, d2=od-2*chamfer, center=true);
            }
        }
        cylinder(h=len+0.2, d=id, center=true);
        if (chamfer > 0) {
            translate([0,0, len/2])
                cylinder(h=2*chamfer+0.2, d1=id-2*chamfer, d2=id, center=true);
            translate([0,0,-len/2])
                cylinder(h=2*chamfer+0.2, d1=id, d2=id-2*chamfer, center=true);
        }
    }
}

heatshrink_sleeve(len=60, id=8, wall=1.5, chamfer=1.2);