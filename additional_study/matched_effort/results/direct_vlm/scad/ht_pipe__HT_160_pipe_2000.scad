$fn = 128;

// HT pipe parameters (mm)
outer_d = 160;
length  = 2000;

// Typical HT pipe wall thickness (approx). Adjust if needed.
wall = 4.7;

module ht_pipe(od, L, t){
    id = od - 2*t;
    difference(){
        cylinder(h=L, d=od, center=false);
        translate([0,0,-0.1])
            cylinder(h=L+0.2, d=id, center=false);
    }
}

ht_pipe(outer_d, length, wall);