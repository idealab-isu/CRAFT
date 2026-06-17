$fn = 120;

// Parameters (mm)
shaft_diameter = 2.0;
shaft_length   = 10.0;   // under-head length
head_diameter  = 3.8;
head_height    = 2.0;

// Internal hex socket (approx for M2 SHCS)
hex_af         = 1.5;    // across flats
socket_depth   = 1.2;

// Small details
tip_chamfer_h  = 0.4;
head_edge_chamfer_h = 0.25;
overlap = 0.02;

// --- Helpers ---
function hex_points_af(af) =
    let(r = af / sqrt(3))  // circumradius for given across-flats
    [ for (i = [0:5]) [ r*cos(60*i), r*sin(60*i) ] ];

module hex_prism_af(af, h) {
    linear_extrude(height = h)
        polygon(points = hex_points_af(af));
}

// --- Model ---
module socket_head_cap_screw() {
    difference() {
        // One connected solid: head + shaft + tip chamfer
        union() {
            // Shaft (from z = -shaft_length to z = 0)
            translate([0, 0, -shaft_length])
                cylinder(h = shaft_length, d = shaft_diameter);

            // Tip chamfer (connected to shaft end)
            translate([0, 0, -shaft_length - tip_chamfer_h + overlap])
                cylinder(h = tip_chamfer_h, d1 = 0, d2 = shaft_diameter);

            // Head (from z = 0 to z = head_height)
            cylinder(h = head_height, d = head_diameter);

            // Slight top edge chamfer to avoid a perfectly sharp rim
            translate([0, 0, head_height - head_edge_chamfer_h])
                cylinder(h = head_edge_chamfer_h, d1 = head_diameter, d2 = head_diameter - 0.3);
        }

        // Internal hex socket cut (from top face downward)
        translate([0, 0, head_height - socket_depth])
            hex_prism_af(hex_af, socket_depth + overlap);
    }
}

socket_head_cap_screw();