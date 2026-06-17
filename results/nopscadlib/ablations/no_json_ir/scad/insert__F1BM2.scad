$fn = 120;

// Parameters (mm)
outer_diameter   = 4.0;
overall_length   = 3.6;

thread_diameter  = 2.0;   // clearance/core for M2 screw
thread_length    = 3.0;   // slightly less than overall length

knurl_depth      = 0.20;  // radial protrusion
knurl_count      = 18;

lead_in_chamfer  = 0.50;
top_chamfer      = 0.50;

eps = 0.02;

// Main
module threaded_insert() {
    difference() {
        // Solid outer body with chamfers + knurl ribs (all connected)
        union() {
            // Base cylinder
            cylinder(h = overall_length, d = outer_diameter, center = true);

            // Bottom chamfer (lead-in) - overlaps into body
            translate([0, 0, -overall_length/2 - eps])
                cylinder(
                    h  = lead_in_chamfer + 2*eps,
                    d1 = outer_diameter - 2*lead_in_chamfer,
                    d2 = outer_diameter,
                    center = false
                );

            // Top chamfer - overlaps into body
            translate([0, 0, overall_length/2 - top_chamfer - eps])
                cylinder(
                    h  = top_chamfer + 2*eps,
                    d1 = outer_diameter,
                    d2 = outer_diameter - 2*top_chamfer,
                    center = false
                );

            // Knurl ribs as ADDITIVE features (not subtracted)
            knurl_ribs();
        }

        // Internal hole (threaded region approximation)
        translate([0, 0, 0])
            cylinder(h = thread_length + 2*eps, d = thread_diameter, center = true);
    }
}

// Additive ribs around the outside
module knurl_ribs() {
    rib_w = knurl_depth;                 // tangential thickness
    rib_len = outer_diameter * 0.90;     // chord length across body
    rib_h = overall_length;              // full height

    // Place ribs so they overlap into the main cylinder by a small amount
    overlap = knurl_depth * 0.6;
    r_place = outer_diameter/2 + knurl_depth/2 - overlap;

    for (i = [0 : knurl_count - 1]) {
        rotate([0, 0, i * 360/knurl_count])
            translate([r_place, 0, 0])
                cube([knurl_depth, rib_len, rib_h], center = true);
    }
}

threaded_insert();