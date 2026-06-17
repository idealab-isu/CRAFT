// Sheet: carbon fiber (single connected solid with subtle weave relief)

// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200;  //[100:400:1]
sheet_thickness = 2; //[1:4:0.1]
corner_radius = 5;  //[2.5:10:0.5]

// Weave relief (kept small but visible)
weave_pitch = 8;     // mm between weave ridges
weave_relief = 0.18; //[0.05:0.4:0.01]
weave_angle = 45;    // degrees
overlap = 0.08;      // ensures unioned solids overlap

$fn = 64;

// Rounded-rectangle prism using linear_extrude of a 2D rounded rectangle
module rounded_rect_prism(L, W, H, R) {
    R2 = min(R, min(L, W)/2 - 0.01);
    linear_extrude(height=H, center=true, convexity=10)
        offset(r=R2)
            square([max(0.01, L - 2*R2), max(0.01, W - 2*R2)], center=true);
}

// 2D diagonal ridge pattern clipped to the sheet outline (rounded rectangle)
module ridge_pattern_2d(L, W, R, pitch, strip_w, angle_deg) {
    R2 = min(R, min(L, W)/2 - 0.01);
    span = sqrt(L*L + W*W) + 2*pitch;

    intersection() {
        // Clip to rounded rectangle footprint
        offset(r=R2)
            square([max(0.01, L - 2*R2), max(0.01, W - 2*R2)], center=true);

        // Repeated strips, rotated
        rotate(angle_deg)
            union() {
                for (x = [-span : pitch : span])
                    translate([x, 0])
                        square([strip_w, 2*span], center=true);
            }
    }
}

// Main module
module carbon_fiber_sheet() {
    L = sheet_length;
    W = sheet_width;
    T = sheet_thickness;
    R = corner_radius;

    // Relief kept within thickness; ensure visible but not excessive
    relief = min(weave_relief, max(0.05, T*0.35));
    strip_w = max(0.8, weave_pitch*0.40);

    // Place relief so it is embedded into the top surface (single connected solid)
    // Relief layer spans from z = T/2 - relief - overlap  to  z = T/2 - overlap
    relief_z = T/2 - relief/2 - overlap/2;

    color([0.06, 0.06, 0.07])
    union() {
        // Base sheet with rounded corners
        rounded_rect_prism(L, W, T, R);

        // Subtle weave: two crossed ridge layers on the top surface (embedded)
        translate([0, 0, relief_z])
            linear_extrude(height=relief + overlap, center=true, convexity=10)
                ridge_pattern_2d(L, W, R, weave_pitch, strip_w, weave_angle);

        translate([0, 0, relief_z])
            linear_extrude(height=relief + overlap, center=true, convexity=10)
                ridge_pattern_2d(L, W, R, weave_pitch, strip_w, -weave_angle);
    }
}

// Render
carbon_fiber_sheet();