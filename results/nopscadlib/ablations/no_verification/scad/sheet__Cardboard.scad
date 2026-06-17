// Corrugated cardboard sheet (single connected solid) - FIXED

// Parameters
sheet_L = 300; //[150:600:1]
sheet_W = 200; //[100:400:1]
sheet_T = 4;   //[2:8:0.1]

corrugation_pitch = 8;    //[4:16:0.1]
corrugation_amp   = 1.5;  //[0.75:3:0.05]
corrugation_wall_T = 0.5; //[0.25:1:0.05]

skin_T = 0.6; //[0.3:1.2:0.05]
edge_chamfer = 1.0; //[0.5:3.0:0.1]

overlap = 0.25; //[0.05:1.0:0.05]  // overlap to guarantee connectivity
marking_depth = 0.2; //[0.1:0.5:0.05]
marking_margin = 20; //[10:60:1]
grain_depth = 0.15; //[0.05:0.4:0.05]
grain_pitch = 12; //[6:30:0.5]

// Quality
$fn = 48;

// Derived
core_T = max(0.2, sheet_T - 2*skin_T);
pitch  = max(0.5, corrugation_pitch);
amp    = min(corrugation_amp, max(0.05, core_T/2 - corrugation_wall_T/2 - 0.05));

// Use enough segments so the flute reads on side/front/back views
n_waves = max(6, ceil(sheet_L / pitch));
step = sheet_L / n_waves;

// Helpers
function clamp(x, a, b) = min(max(x, a), b);

// Top and bottom liners
module liner(zc) {
    translate([0, 0, zc])
        cube([sheet_L, sheet_W, skin_T], center=true);
}

// Corrugated medium as a continuous "ribbon" (thickened polyline) extruded along Y.
// This produces a clear liner+flute cross-section on ALL side views.
module corrugation_core() {
    // Build a smooth-ish polyline using a sine wave sampled along X
    // (polygon is a thick ribbon around the centerline)
    samples = max(80, n_waves * 12);
    dx = sheet_L / samples;

    // Centerline points in X-Z
    pts = [
        for (i = [0 : samples])
            let(x = -sheet_L/2 + i*dx,
                z = amp * sin(360 * x / pitch))
            [x, z]
    ];

    // Thicken the centerline into a ribbon and extrude along Y
    // Keep it inside the core region and overlap into liners for union.
    linear_extrude(height = sheet_W, center=true, convexity=10)
        offset(delta = corrugation_wall_T/2)
            polygon(points = concat(
                pts,
                // close polygon by returning along a slightly shifted copy
                [ for (i = [samples : -1 : 0])
                    let(x = -sheet_L/2 + i*dx,
                        z = amp * sin(360 * x / pitch) - 0.001)
                    [x, z]
                ]
            ));
}

// Simple edge chamfer by subtracting wedges on all 4 sides (keeps one connected solid)
module chamfer_edges() {
    // Along +X and -X
    for (sx = [-1, 1]) {
        translate([sx*(sheet_L/2 - edge_chamfer/2), 0, 0])
            rotate([0, 45*sx, 0])
                cube([edge_chamfer*2, sheet_W + 2, sheet_T + 2], center=true);
    }
    // Along +Y and -Y
    for (sy = [-1, 1]) {
        translate([0, sy*(sheet_W/2 - edge_chamfer/2), 0])
            rotate([45*sy, 0, 0])
                cube([sheet_L + 2, edge_chamfer*2, sheet_T + 2], center=true);
    }
}

// Subtle surface grain as shallow grooves (difference)
module surface_grain_cut(zsign=1) {
    zc = zsign*(sheet_T/2 - grain_depth/2);
    usable_L = sheet_L - 2*edge_chamfer;
    usable_W = sheet_W - 2*edge_chamfer;
    n = max(1, floor(usable_W / grain_pitch));

    for (i = [0 : n-1]) {
        y = -usable_W/2 + (i + 0.5) * (usable_W/n);
        translate([0, y, zc])
            cube([usable_L, grain_pitch*0.35, grain_depth], center=true);
    }
}

// Printed marking as shallow inset (difference)
module printed_marking_cut() {
    usable_L = sheet_L - 2*marking_margin;
    usable_W = sheet_W/3;
    translate([0, 0, sheet_T/2 - marking_depth/2])
        cube([usable_L, usable_W, marking_depth], center=true);
}

// Final model
module corrugated_cardboard_sheet() {
    difference() {
        union() {
            // Liners
            liner( sheet_T/2 - skin_T/2);
            liner(-sheet_T/2 + skin_T/2);

            // Corrugated core: place within core region and overlap into liners
            // Ensure Z thickness reaches slightly into both liners for a single connected solid.
            scale([1, 1, (core_T + 2*overlap)/core_T])
                corrugation_core();
        }

        // Edge chamfers
        chamfer_edges();

        // Surface grain (top and bottom)
        surface_grain_cut( 1);
        surface_grain_cut(-1);

        // Printed marking inset
        printed_marking_cut();
    }
}

corrugated_cardboard_sheet();