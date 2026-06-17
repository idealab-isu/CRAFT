// Wing nut for 4.0mm screw, 10.0mm across flats, 3.75mm thick

$fn = 96;

// Parameters
across_flats = 10.0;          //[5.0:20.0:0.1]
thickness    = 3.75;          //[2.0:8.0:0.05]

// Hole (clearance for 4.0mm screw)
hole_d = 4.0;                 //[3.5:5.0:0.05]

// Wings (two lobes)
wing_span      = 22.0;        //[12.0:44.0:0.5]   // tip-to-tip overall span
wing_width     = 6.0;         //[3.0:12.0:0.25]   // max wing width (Y direction)
wing_thickness = 3.75;        //[1.5:6.0:0.1]     // wing thickness (Z), clamped to nut thickness
wing_tip_r     = 3.0;         //[0.8:6.0:0.1]     // rounding at wing tips
wing_root_r    = 2.0;         //[0.5:4.0:0.1]     // rounding at wing root

// Edge chamfer
edge_chamfer = 0.5;           //[0.0:1.5:0.05]

// Connectivity overlap
overlap = 0.25;               //[0.05:1.0:0.05]

// Derived
hex_R   = across_flats / sqrt(3);                 // circumradius for hex with given across-flats
wing_len = max(0, wing_span/2 - across_flats/2);  // extension beyond hex flats
wing_z  = min(wing_thickness, thickness);

// Hex prism (across flats = across_flats)
module hex_body() {
    rotate([0,0,30])
        cylinder(r=hex_R, h=thickness, center=true, $fn=6);
}

// Chamfer by subtracting two shallow cones (keeps one connected solid)
module edge_chamfer_cut() {
    if (edge_chamfer > 0) {
        // Top chamfer
        translate([0,0, thickness/2 - edge_chamfer/2])
            cylinder(h=edge_chamfer + 2*overlap,
                     r1=hex_R + edge_chamfer,
                     r2=hex_R - edge_chamfer,
                     center=true, $fn=96);
        // Bottom chamfer
        translate([0,0,-thickness/2 + edge_chamfer/2])
            cylinder(h=edge_chamfer + 2*overlap,
                     r1=hex_R - edge_chamfer,
                     r2=hex_R + edge_chamfer,
                     center=true, $fn=96);
    }
}

// One wing lobe (positive X), rounded and connected to hex
module wing_pos() {
    // Ensure the wing overlaps into the hex so it is one connected solid
    x_root = across_flats/2 - overlap;          // starts slightly inside hex flat
    x_tip  = across_flats/2 + wing_len;         // outermost tip position from center

    // Keep radii sane relative to available length
    rr = min(wing_root_r, max(0.01, (x_tip - x_root)/2));
    tr = min(wing_tip_r,  max(0.01, (x_tip - x_root)/2));

    // Wing is a lobe (not a rectangular bar): hull of two "capsules" plus a waist control
    hull() {
        // Root round (bigger) to blend into nut body
        translate([x_root + rr, 0, 0])
            cylinder(r=rr, h=wing_z + 2*overlap, center=true, $fn=64);

        // Tip round (smaller/rounded)
        translate([x_tip - tr, 0, 0])
            cylinder(r=tr, h=wing_z + 2*overlap, center=true, $fn=64);

        // Waist control to set overall wing width without making it a long rectangle
        translate([x_root + (x_tip - x_root)*0.55, 0, 0])
            cylinder(r=max(0.01, wing_width/2), h=wing_z + 2*overlap, center=true, $fn=64);
    }
}

// Both wings
module wings() {
    union() {
        wing_pos();
        mirror([1,0,0]) wing_pos();
    }
}

// Final model
difference() {
    union() {
        hex_body();
        wings();
    }

    // Chamfer cuts
    edge_chamfer_cut();

    // Through hole for 4.0mm screw (clearance)
    cylinder(d=hole_d, h=thickness + 4*overlap, center=true, $fn=96);
}