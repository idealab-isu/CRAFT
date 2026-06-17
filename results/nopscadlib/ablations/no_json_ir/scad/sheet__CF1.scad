$fn = 96;

// Parameters for the carbon-fiber sheet
sheet_length    = 100; // X
sheet_width     = 50;  // Y
sheet_thickness = 2;   // Z
corner_radius   = 5;   // rounded corner radius
chamfer_size    = 1;   // edge chamfer size

// Visual-only "carbon fiber" weave (does not change geometry)
weave_pitch = 4;       // spacing of weave cells
weave_depth = 0.12;    // shallow surface relief

eps = 0.01;

module rounded_rect_2d(L, W, R) {
    R2 = min(R, min(L, W)/2 - eps);
    minkowski() {
        square([L - 2*R2, W - 2*R2], center=true);
        circle(r=R2);
    }
}

module sheet_solid() {
    // One connected solid: rounded plate with a top chamfer (bevel)
    union() {
        // Base thickness up to start of chamfer
        linear_extrude(height = max(sheet_thickness - chamfer_size, eps))
            rounded_rect_2d(sheet_length, sheet_width, corner_radius);

        // Chamfered top section (tapers inward)
        translate([0, 0, max(sheet_thickness - chamfer_size, eps)])
            linear_extrude(height = chamfer_size, scale = [
                (sheet_length - 2*chamfer_size) / sheet_length,
                (sheet_width  - 2*chamfer_size) / sheet_width
            ])
                rounded_rect_2d(sheet_length, sheet_width, corner_radius);
    }
}

module weave_relief() {
    // Subtle cross-hatch relief on the top face to suggest carbon fiber
    // Kept shallow and clipped to the sheet outline.
    intersection() {
        // Clip region: slightly inset top face area
        translate([0, 0, sheet_thickness - weave_depth])
            linear_extrude(height = weave_depth + eps)
                rounded_rect_2d(sheet_length - 2*chamfer_size, sheet_width - 2*chamfer_size, max(corner_radius - chamfer_size, eps));

        // Two diagonal stripe sets
        union() {
            for (a = [45, -45]) {
                rotate([0, 0, a])
                    translate([0, 0, sheet_thickness - weave_depth])
                        linear_extrude(height = weave_depth + eps)
                            for (i = [-ceil((sheet_length+sheet_width)/weave_pitch) : ceil((sheet_length+sheet_width)/weave_pitch)]) {
                                translate([i*weave_pitch, 0, 0])
                                    square([weave_pitch*0.55, sheet_length + sheet_width], center=true);
                            }
            }
        }
    }
}

module carbon_fiber_sheet() {
    // Geometry + visual weave; still one connected solid (weave is unioned)
    color([0.08, 0.09, 0.10])  // dark carbon-like base
    union() {
        sheet_solid();
        weave_relief();
    }
}

carbon_fiber_sheet();