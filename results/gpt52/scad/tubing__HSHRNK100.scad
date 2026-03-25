$fn=96;

module heatshrink_sleeve(len=50, id=10, wall=1.0, chamfer=0.8) {
    od = id + 2*wall;
    difference() {
        union() {
            cylinder(h=len, d=od, center=true);
            if (chamfer > 0) {
                translate([0,0, len/2])
                    cylinder(h=chamfer*2, d1=od, d2=od-2*chamfer, center=true);
                translate([0,0,-len/2])
                    cylinder(h=chamfer*2, d1=od-2*chamfer, d2=od, center=true);
            }
        }
        cylinder(h=len+0.2, d=id, center=true);
        if (chamfer > 0) {
            translate([0,0, len/2])
                cylinder(h=chamfer*2+0.2, d1=id, d2=id+2*chamfer, center=true);
            translate([0,0,-len/2])
                cylinder(h=chamfer*2+0.2, d1=id+2*chamfer, d2=id, center=true);
        }
    }
}

module sleeve_set() {
    union() {
        heatshrink_sleeve(len=60, id=12, wall=1.2, chamfer=1.0);
        translate([0,0, 70]) heatshrink_sleeve(len=40, id=8, wall=1.0, chamfer=0.8);
        translate([0,0,-70]) heatshrink_sleeve(len=30, id=6, wall=0.9, chamfer=0.7);
    }
}

heatshrink_sleeve(len=60, id=12, wall=1.2, chamfer=1.0);