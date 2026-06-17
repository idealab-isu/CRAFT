// Sheet: carbon fiber (single connected solid)
// Fixes: non-empty geometry, proper rounded rectangle, visible thickness, subtle weave relief
$fn = 96;

// Parameters
sheet_length    = 300; //[150:600:1]
sheet_width     = 200; //[100:400:1]
sheet_thickness = 2;   //[1:4:0.5]
corner_radius   = 10;  //[5:20:1]
chamfer_size    = 0.8; //[0.3:2:0.1]

// Weave relief (pure geometry; no text/labels)
weave_pitch     = 6;    // spacing of weave ridges
weave_width     = 1.2;  // ridge width
weave_depth     = 0.18; // ridge height (kept small vs thickness)
weave_margin    = 2;    // keep relief away from edges

eps = 0.02;

// 2D rounded rectangle (robust, no self-subtraction)
module rounded_rect_2d(L, W, R) {
    R2 = min(R, min(L, W)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R2), sy*(W/2 - R2)])
                circle(r=R2);
    }
}

// Base sheet with rounded corners
module sheet_base() {
    linear_extrude(height=sheet_thickness, center=true, convexity=10)
        rounded_rect_2d(sheet_length, sheet_width, corner_radius);
}

// Simple chamfer by subtracting a slightly smaller, slightly shifted copy (top & bottom)
module chamfer_cut() {
    // Ensure chamfer doesn't exceed half thickness
    cs = min(chamfer_size, sheet_thickness/2 - eps);

    // Outer "wedge" volume to remove from the base
    difference() {
        // Slightly larger than base in Z so it fully intersects
        linear_extrude(height=sheet_thickness + 2*eps, center=true, convexity=10)
            rounded_rect_2d(sheet_length, sheet_width, corner_radius);

        // Keep a smaller core, leaving a rim to be removed; shift in Z to create bevel
        // Top bevel
        translate([0, 0,  cs/2])
            linear_extrude(height=sheet_thickness - cs + 2*eps, center=true, convexity=10)
                rounded_rect_2d(sheet_length - 2*cs, sheet_width - 2*cs, max(corner_radius - cs, 0));

        // Bottom bevel
        translate([0, 0, -cs/2])
            linear_extrude(height=sheet_thickness - cs + 2*eps, center=true, convexity=10)
                rounded_rect_2d(sheet_length - 2*cs, sheet_width - 2*cs, max(corner_radius - cs, 0));
    }
}

// Subtle carbon-fiber weave relief (adds tiny ridges on top surface only)
module weave_relief() {
    // Limit relief area to inside margins
    Lr = max(sheet_length - 2*weave_margin, 0);
    Wr = max(sheet_width  - 2*weave_margin, 0);

    // Place relief on top face with slight overlap into the sheet for watertight union
    z0 = sheet_thickness/2 - weave_depth/2 + eps;

    intersection() {
        // Clip to inner rounded rectangle so ridges don't spill over edges
        translate([0, 0, z0])
            linear_extrude(height=weave_depth + 2*eps, center=true, convexity=10)
                rounded_rect_2d(Lr, Wr, max(corner_radius - weave_margin, 0));

        // Two diagonal ridge sets (0/90 in a rotated frame -> +/-45 on the sheet)
        union() {
            // +45°
            rotate([0, 0, 45])
                translate([0, 0, z0])
                    for (x = [-(sheet_length+sheet_width) : weave_pitch : (sheet_length+sheet_width)])
                        translate([x, 0, 0])
                            cube([weave_width, 2*(sheet_length+sheet_width), weave_depth + 2*eps], center=true);

            // -45°
            rotate([0, 0, -45])
                translate([0, 0, z0])
                    for (x = [-(sheet_length+sheet_width) : weave_pitch : (sheet_length+sheet_width)])
                        translate([x, 0, 0])
                            cube([weave_width, 2*(sheet_length+sheet_width), weave_depth + 2*eps], center=true);
        }
    }
}

// Final single connected solid
module final_assembly() {
    color([0.08, 0.09, 0.10])  // dark carbon-like
    union() {
        // Base with chamfered edges
        difference() {
            sheet_base();
            chamfer_cut();
        }
        // Subtle weave texture (still one solid)
        weave_relief();
    }
}

final_assembly();