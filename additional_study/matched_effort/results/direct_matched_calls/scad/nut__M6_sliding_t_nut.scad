$fn = 80;

// T-slot nut parameters (mm)
screw_d = 6.0;          // screw size (M6 nominal)
across_flats = 8.0;     // hex across flats
thickness = 6.6;        // nut thickness

// Practical clearances (mm)
hole_clear = 0.4;       // clearance on screw hole diameter
hex_clear  = 0.15;      // clearance on hex pocket across flats (if used)
chamfer_h  = 0.6;       // top/bottom edge chamfer height

// T-slot nut body sizing (generic, printable, fits many 8/10-series slots)
// Adjust these if you have a specific extrusion slot standard.
body_len = 18.0;
body_wid = 10.0;

// Anti-rotation nibs (optional)
nibs_on = true;
nib_len = 3.0;
nib_wid = 1.2;
nib_h   = 1.0;

// Derived
hole_d = screw_d + hole_clear;
hex_flat = across_flats + hex_clear;
hex_r = hex_flat / sqrt(3); // circumradius for hex with given across-flats

module chamfered_block(l, w, h, c) {
    // Chamfer top and bottom edges by subtracting 45° wedges
    difference() {
        cube([l, w, h], center=true);

        // Top chamfer
        translate([0, 0, h/2 - c/2])
            rotate([0, 45, 0])
                cube([l*2, w*2, c], center=true);

        translate([0, 0, h/2 - c/2])
            rotate([45, 0, 0])
                cube([l*2, w*2, c], center=true);

        // Bottom chamfer
        translate([0, 0, -h/2 + c/2])
            rotate([0, 45, 0])
                cube([l*2, w*2, c], center=true);

        translate([0, 0, -h/2 + c/2])
            rotate([45, 0, 0])
                cube([l*2, w*2, c], center=true);
    }
}

module tslot_nut() {
    difference() {
        union() {
            chamfered_block(body_len, body_wid, thickness, chamfer_h);

            if (nibs_on) {
                // Two small nibs on the long sides to help prevent rotation in slot
                translate([0,  body_wid/2 + nib_wid/2, -thickness/2 + nib_h/2])
                    cube([nib_len, nib_wid, nib_h], center=true);
                translate([0, -body_wid/2 - nib_wid/2, -thickness/2 + nib_h/2])
                    cube([nib_len, nib_wid, nib_h], center=true);
            }
        }

        // Through hole for M6 screw
        cylinder(d=hole_d, h=thickness + 2, center=true);

        // Optional hex pocket on one face (for captive nut behavior if desired)
        // Here we include a shallow hex recess on the top face.
        translate([0, 0, thickness/2 - 2.2/2])
            cylinder(r=hex_r, h=2.2 + 0.2, center=true, $fn=6);
    }
}

tslot_nut();