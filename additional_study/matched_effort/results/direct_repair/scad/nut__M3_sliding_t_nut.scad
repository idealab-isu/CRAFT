$fn = 80;

// Parameters (mm)
screw_d = 3.0;          // for M3 clearance
nut_af  = 6.0;          // across flats
thk     = 3.0;          // thickness

// Clearances
hole_d  = 3.4;          // typical M3 clearance
chamfer = 0.35;         // small edge chamfer

module hex_prism_af(af, h){
    // Hex with given across-flats (af)
    // For a regular hex, across-flats = 2*apothem = sqrt(3)*R (circumradius)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module tslot_nut(){
    difference(){
        // Body with slight chamfer via minkowski (kept small to remain renderable)
        // Use a simple chamfer approximation: hull of two hexes
        hull(){
            translate([0,0, chamfer]) hex_prism_af(nut_af, thk - 2*chamfer);
            hex_prism_af(nut_af - 2*chamfer, thk);
        }

        // Through hole
        translate([0,0,-0.5]) cylinder(h=thk+1.0, d=hole_d);

        // Light countersink on both sides for easier screw start
        translate([0,0,-0.01]) cylinder(h=0.7, d1=hole_d+1.2, d2=hole_d);
        translate([0,0,thk-0.69]) cylinder(h=0.7, d1=hole_d, d2=hole_d+1.2);
    }
}

tslot_nut();