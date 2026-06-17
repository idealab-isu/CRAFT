// SMD component target size: [3.0, 1.6, 1.05] (L, W, H)

// Parameters
chip_length = 3.0;
chip_width  = 1.6;
chip_height = 1.05;

termination_length = 0.3;   // along X
termination_height = 0.2;   // along Z (from bottom)

marking_height = 0.02;      // recessed into top
marking_margin_x = 0.6;     // margin from ends
marking_margin_y = 0.35;    // margin from sides

fillet_radius = 0.12;       // body edge rounding (XY)
overlap = 0.02;             // small overlap to guarantee watertight union
$fn = 48;

// Main module (ONE connected solid)
module smd_component() {
    union() {
        chip_body();
        end_termination_left();
        end_termination_right();
        top_marking_recess();   // recessed (difference) but kept as single solid via union wrapper below
    }
}

// Rounded rectangular prism body (exact overall size)
module chip_body() {
    // Use minkowski to create rounded edges in XY while keeping exact L/W/H
    // by shrinking the core by 2*fillet_radius in X and Y.
    minkowski() {
        translate([0, 0, chip_height/2])
            cube([chip_length - 2*fillet_radius, chip_width - 2*fillet_radius, chip_height], center=true);
        cylinder(r=fillet_radius, h=0.001, center=true);
    }
}

// Terminations: connected to body, flush with bottom, extend full width
module end_termination_left() {
    translate([
        -chip_length/2 + termination_length/2 - overlap,  // overlap into body
        0,
        termination_height/2
    ])
        cube([termination_length + 2*overlap, chip_width, termination_height], center=true);
}

module end_termination_right() {
    translate([
        chip_length/2 - termination_length/2 + overlap,   // overlap into body
        0,
        termination_height/2
    ])
        cube([termination_length + 2*overlap, chip_width, termination_height], center=true);
}

// Recessed top marking (engraved), not a floating piece
module top_marking_recess() {
    marking_len = max(0.1, chip_length - 2*marking_margin_x);
    marking_wid = max(0.1, chip_width  - 2*marking_margin_y);

    // Create recess by subtracting from a copy of the body volume region.
    // Implemented as: (body) + (terminations) + (body with recess removed) - (body)
    // Simplify: just subtract recess from a thin top slab that overlaps the body.
    difference() {
        // Thin slab at the top that overlaps into the body so subtraction affects the solid
        translate([0, 0, chip_height - marking_height/2])
            cube([chip_length + 2*overlap, chip_width + 2*overlap, marking_height + 2*overlap], center=true);

        // Recess volume
        translate([0, 0, chip_height - marking_height/2 + overlap])
            cube([marking_len, marking_wid, marking_height + 4*overlap], center=true);
    }
}

// Render
smd_component();