$fn = 128;

// Heatshrink sleeving (tubing)
inner_d = 6;          // inner diameter (mm)
wall = 0.6;           // wall thickness (mm)
length = 40;          // length (mm)

outer_d = inner_d + 2*wall;

module heatshrink_sleeve(id=6, wall=0.6, len=40) {
    od = id + 2*wall;
    difference() {
        cylinder(h=len, d=od, center=false);
        translate([0,0,-0.2])
            cylinder(h=len+0.4, d=id, center=false);
    }
}

heatshrink_sleeve(inner_d, wall, length);