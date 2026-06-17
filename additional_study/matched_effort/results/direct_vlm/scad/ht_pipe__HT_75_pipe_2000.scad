$fn = 128;

// HT pipe parameters (mm)
outer_d = 75;        // outer diameter
length  = 2000;      // pipe length
wall    = 2.7;       // wall thickness
inner_d = outer_d - 2*wall;

module ht_pipe(od, id, L){
    eps = 0.2; // small overlap to avoid coincident faces
    difference(){
        // Orient pipe along X so side/front/back views show the tube clearly
        rotate([0, 90, 0])
            cylinder(h=L, d=od, center=true);

        // Inner void slightly longer to ensure clean subtraction at both ends
        rotate([0, 90, 0])
            cylinder(h=L + 2*eps, d=id, center=true);
    }
}

ht_pipe(outer_d, inner_d, length);