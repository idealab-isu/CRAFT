$fn = 180;

// HT pipe parameters (mm)
outer_d = 160;      // nominal HT 160 outer diameter
length  = 500;      // pipe length
wall    = 4.7;      // typical HT 160 wall thickness (approx.)
inner_d = outer_d - 2*wall;

module ht_pipe(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.5])
            cylinder(d=id, h=h+1, center=false);
    }
}

ht_pipe(outer_d, inner_d, length);