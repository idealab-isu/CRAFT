$fn = 128;

// Heatshrink sleeving (tubing)
inner_d = 6;        // mm
wall = 0.6;         // mm
length = 60;        // mm

outer_d = inner_d + 2*wall;

module heatshrink_sleeve(id, od, h) {
    difference() {
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.2])
            cylinder(d=id, h=h+0.4, center=false);
    }
}

heatshrink_sleeve(inner_d, outer_d, length);