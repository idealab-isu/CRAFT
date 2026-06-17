$fn = 64;

// Target bracket size (overall bounding box)
overall_length = 38;   // X
overall_width  = 31;   // Y
thickness      = 8.5;  // Z

// Bracket details (typical extrusion corner bracket style)
leg_width = 16;                 // width of each leg band
inner_relief = 14;              // square cutout at inner corner (reduces mass, typical look)
hole_diameter = 5.2;            // clearance for M5
hole_edge_margin = 8;           // from each outer edge along the leg
hole_spacing = 16;              // spacing between the two holes on the long leg
overlap = 0.25;                 // boolean robustness

module bracket_L() {
    difference() {
        // Base L plate (one connected solid)
        union() {
            // X-leg band
            translate([0, -(overall_width/2 - leg_width/2), 0])
                cube([overall_length, leg_width, thickness], center=true);

            // Y-leg band
            translate([-(overall_length/2 - leg_width/2), 0, 0])
                cube([leg_width, overall_width, thickness], center=true);
        }

        // Inner corner relief (kept inside the L so outer bounding box stays [38,31,8.5])
        translate([
            -overall_length/2 + leg_width + inner_relief/2,
            -overall_width/2  + leg_width + inner_relief/2,
            0
        ])
            cube([inner_relief, inner_relief, thickness + 2*overlap], center=true);

        // Hole pattern: 2 holes on the long (X) leg, 1 hole on the short (Y) leg
        // X-leg holes (along X, centered in the leg width)
        for (xpos = [
            -overall_length/2 + hole_edge_margin,
            -overall_length/2 + hole_edge_margin + hole_spacing
        ]) {
            translate([xpos, -overall_width/2 + leg_width/2, 0])
                cylinder(d=hole_diameter, h=thickness + 2*overlap, center=true);
        }

        // Y-leg hole (along Y, centered in the leg width)
        translate([-overall_length/2 + leg_width/2, -overall_width/2 + hole_edge_margin, 0])
            cylinder(d=hole_diameter, h=thickness + 2*overlap, center=true);
    }
}

bracket_L();