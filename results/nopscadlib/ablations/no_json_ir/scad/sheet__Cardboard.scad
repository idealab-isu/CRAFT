// Corrugated cardboard sheet (single connected solid)

// Parameters
sheet_length    = 200;  // X
sheet_width     = 100;  // Y
sheet_thickness = 5;    // Z total

corner_radius   = 5;    // rounded corners

// Corrugation parameters
liner_th        = 0.8;  // thickness of each flat liner
flute_height    = 3.0;  // peak-to-valley height of corrugation (must fit between liners)
flute_pitch     = 10;   // distance between peaks
wall_th         = 0.9;  // thickness of corrugated web

// Quality
$fn = 48;

eps = 0.02;

// Derived
core_gap = sheet_thickness - 2*liner_th;                 // space between liners
flute_amp = min(flute_height/2, max(0.01, core_gap/2));  // amplitude (centered in core)
assert(core_gap > 0, "liner_th too large for sheet_thickness");
assert(flute_amp > 0, "flute_height too small or liners consume all thickness");

// 2D rounded rectangle (centered)
module rounded_rect_2d(L, W, R) {
    R2 = min(R, min(L, W)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R2), sy*(W/2 - R2)])
                circle(r=R2);
    }
}

// 3D rounded slab (centered)
module rounded_slab(L, W, H, R) {
    linear_extrude(height=H, center=true)
        rounded_rect_2d(L, W, R);
}

// Corrugated web as a union of thin "ribs" following a sine wave along X,
// extruded across Y. This guarantees a connected solid with the liners.
module corrugated_web(L, W, core_gap, amp, pitch, t) {
    // Place web centered in Z within the core
    // Web spans from -core_gap/2..+core_gap/2, with sine centered at 0.
    steps = max(60, ceil(L * 2)); // resolution along length
    dx = L / steps;

    union() {
        for (i = [0 : steps-1]) {
            x0 = -L/2 + i*dx;
            x1 = x0 + dx;

            z0 = amp * sin(360 * (x0 + L/2) / pitch);
            z1 = amp * sin(360 * (x1 + L/2) / pitch);

            // Rib is a hull between two thin rectangles at x0 and x1
            // Extruded across full width W.
            hull() {
                translate([x0, 0, z0])
                    cube([t, W, t], center=true);
                translate([x1, 0, z1])
                    cube([t, W, t], center=true);
            }
        }
    }
}

// Full cardboard sheet (single connected solid)
module cardboard_sheet() {
    union() {
        // Bottom liner
        translate([0, 0, -sheet_thickness/2 + liner_th/2])
            rounded_slab(sheet_length, sheet_width, liner_th, corner_radius);

        // Top liner
        translate([0, 0,  sheet_thickness/2 - liner_th/2])
            rounded_slab(sheet_length, sheet_width, liner_th, corner_radius);

        // Corrugated core web (slightly inset from edges to avoid corner artifacts)
        // Inset is formula-based from wall thickness and corner radius.
        inset = max(wall_th*1.5, min(corner_radius*0.35, 2));
        translate([0, 0, 0])
            intersection() {
                corrugated_web(sheet_length, sheet_width, core_gap, flute_amp, flute_pitch, wall_th);
                // Clip to rounded footprint so everything stays within the sheet outline
                rounded_slab(sheet_length - 2*inset, sheet_width - 2*inset, core_gap + 2*wall_th, max(0, corner_radius - inset));
            }

        // Small overlaps to ensure manifold connectivity between web and liners
        // (web already touches, but this makes it robust)
        translate([0, 0, -sheet_thickness/2 + liner_th + eps/2])
            rounded_slab(sheet_length - 2*eps, sheet_width - 2*eps, eps, max(0, corner_radius - eps));
        translate([0, 0,  sheet_thickness/2 - liner_th - eps/2])
            rounded_slab(sheet_length - 2*eps, sheet_width - 2*eps, eps, max(0, corner_radius - eps));
    }
}

cardboard_sheet();