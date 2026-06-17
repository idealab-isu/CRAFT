$fn = 128;

// HT 90 pipe 1000 mm (interpreted as: DN90 sewer pipe, 1000 mm length)
// Typical DN90 HT pipe: OD ~ 90 mm, wall thickness ~ 2.7 mm
// Adjust parameters as needed.

length_mm = 1000;
outer_d_mm = 90;
wall_th_mm = 2.7;

module ht_pipe(len=1000, od=90, wall=2.7) {
    difference() {
        cylinder(h=len, d=od, center=false);
        translate([0,0,-0.5])
            cylinder(h=len+1, d=od-2*wall, center=false);
    }
}

ht_pipe(length_mm, outer_d_mm, wall_th_mm);