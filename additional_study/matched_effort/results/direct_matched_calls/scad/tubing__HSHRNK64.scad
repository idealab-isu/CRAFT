$fn = 128;

// Heatshrink sleeving (tubing)
inner_d = 6;          // mm
wall = 0.6;           // mm
length = 60;          // mm

outer_d = inner_d + 2*wall;

module heatshrink_sleeve(id=6, wall=0.6, h=60) {
    od = id + 2*wall;
    difference() {
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.5])
            cylinder(d=id, h=h+1, center=false);
    }
}

heatshrink_sleeve(inner_d, wall, length);