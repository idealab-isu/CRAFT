$fn = 80;

// T-slot nut parameters (mm)
screw_d = 4.0;          // screw size (clearance hole)
across_flats = 6.0;     // hex across flats
thickness = 3.7;        // nut thickness

// Practical clearances/tweaks
hole_clearance = 0.4;   // added to screw_d for clearance
hex_clearance  = 0.15;  // added to across_flats for print/fit
edge_chamfer   = 0.35;  // small chamfer on top/bottom edges

module hex_prism_af(af, h){
    // Regular hex with given across-flats:
    // circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module chamfered_hex_nut(af, h, chamfer){
    // Create a simple chamfer by hulling two slightly different hex prisms
    // near the ends.
    chamfer = min(chamfer, h/2 - 0.01);
    hull(){
        translate([0,0,0]) hex_prism_af(af - 2*chamfer, 0.01);
        translate([0,0,chamfer]) hex_prism_af(af, 0.01);
    }
    translate([0,0,chamfer])
        hex_prism_af(af, h - 2*chamfer);
    hull(){
        translate([0,0,h - chamfer]) hex_prism_af(af, 0.01);
        translate([0,0,h]) hex_prism_af(af - 2*chamfer, 0.01);
    }
}

difference(){
    chamfered_hex_nut(across_flats + hex_clearance, thickness, edge_chamfer);

    // Through hole for screw
    translate([0,0,-0.2])
        cylinder(h=thickness + 0.4, d=screw_d + hole_clearance, $fn=80);
}