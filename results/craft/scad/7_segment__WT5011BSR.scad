// Single connected solid: 7-seg body only (no pins/leads)
// Overall dimensions must match: [12.7, 19, 8.2]  => [X, Y, Z]

$fn = 64;

// Parameters (mm)
body_width  = 12.7;  // X
body_height = 19;    // Y
body_depth  = 8.2;   // Z

bezel_thickness = 1.2;
bezel_frame     = 1.0;

cutout_depth      = 1.6;
segment_thickness = 1.6;
segment_margin    = 1.6;
segment_gap       = 1.2;

dp_radius = 1.0;
dp_depth  = 1.6;

// Small overlap to guarantee manifold unions/differences
eps = 0.05;

// Derived
front_z =  body_depth/2;
back_z  = -body_depth/2;

// Main body block
module main_body() {
    cube([body_width, body_height, body_depth], center=true);
}

// Bezel as a raised frame on the front face, fused to body
module front_bezel_solid() {
    // Ensure bezel is a real solid frame (non-zero wall thickness)
    inner_w = max(0.01, body_width  - 2*bezel_frame);
    inner_h = max(0.01, body_height - 2*bezel_frame);

    // Place bezel so its back face slightly intersects the body front face
    translate([0, 0, front_z - eps + bezel_thickness/2])
        difference() {
            cube([body_width, body_height, bezel_thickness], center=true);
            cube([inner_w, inner_h, bezel_thickness + 2*eps], center=true);
        }
}

// Segment cutouts (subtracted from body)
module segment_cutout(x, y) {
    seg_w = max(0.01, body_width - 2*segment_margin);
    translate([x, y, front_z - cutout_depth/2 + eps])
        cube([seg_w, segment_thickness, cutout_depth + 2*eps], center=true);
}

module vertical_segment_cutout(x, y) {
    vlen = (body_height - 2*segment_margin - 3*segment_thickness - 2*segment_gap)/2;
    vlen = max(0.01, vlen);
    translate([x, y, front_z - cutout_depth/2 + eps])
        cube([segment_thickness, vlen, cutout_depth + 2*eps], center=true);
}

module seven_segment_cutouts() {
    vlen = (body_height - 2*segment_margin - 3*segment_thickness - 2*segment_gap)/2;
    vlen = max(0.01, vlen);

    y_top =  body_height/2 - segment_margin - segment_thickness/2; // A
    y_bot = -body_height/2 + segment_margin + segment_thickness/2; // D
    y_mid = 0;                                                     // G

    // Centers for vertical segments (B,C,F,E)
    y_v = (segment_thickness + segment_gap)/2 + vlen/2;
    x_l = -body_width/2 + segment_margin + segment_thickness/2;
    x_r =  body_width/2 - segment_margin - segment_thickness/2;

    union() {
        segment_cutout(0, y_top); // A
        segment_cutout(0, y_mid); // G
        segment_cutout(0, y_bot); // D

        vertical_segment_cutout(x_l,  y_v); // F
        vertical_segment_cutout(x_r,  y_v); // B
        vertical_segment_cutout(x_l, -y_v); // E
        vertical_segment_cutout(x_r, -y_v); // C
    }
}

module decimal_point_cutout() {
    // Keep DP fully inside the body footprint (avoid tangency/degenerate cuts)
    dp_x = body_width/2  - segment_margin - dp_radius;
    dp_y = -body_height/2 + segment_margin + dp_radius;

    translate([dp_x, dp_y, front_z - dp_depth/2 + eps])
        cylinder(r=dp_radius, h=dp_depth + 2*eps, center=true);
}

// Complete model: one connected solid (body + bezel), with cutouts removed
module complete_model() {
    union() {
        // Body with recessed segment/DP pockets
        difference() {
            main_body();
            union() {
                seven_segment_cutouts();
                decimal_point_cutout();
            }
        }

        // Raised bezel frame, fused to body with slight overlap
        front_bezel_solid();
    }
}

complete_model();