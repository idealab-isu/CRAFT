// Miniature linear guide rail (single connected solid)
// Target overall size: 15mm (X) wide, 15mm (Z) tall, 100mm (Y) long

$fn = 64;

// Parameters
rail_length = 100.0; //[50.0:200.0:1]
rail_width  = 15.0;  //[7.5:30.0:0.5]
rail_height = 15.0;  //[7.5:30.0:0.5]

// Rail detailing
side_groove_depth = 1.2; //[0.5:3.0:0.1]
side_groove_height = 4.0; //[2.0:8.0:0.1]
side_groove_z = 0.0; // centered about mid-height

top_relief_depth = 0.8; //[0.0:2.0:0.1]
top_relief_width = 7.0; //[3.0:12.0:0.1]

bottom_relief_depth = 0.6; //[0.0:2.0:0.1]
bottom_relief_width = 9.0; //[3.0:14.0:0.1]

// Mounting holes (counterbored)
hole_diameter = 3.5; //[2.0:7.0:0.1]
counterbore_diameter = 6.5; //[4.0:10.0:0.1]
counterbore_depth = 2.5; //[1.0:6.0:0.1]
hole_count = 4; //[2:8:1]
hole_edge_margin = 12.0; //[6.0:24.0:0.5]

// Edge rounding (kept modest to avoid blank/degenerate geometry)
edge_round = 0.6; //[0.0:1.5:0.1]
eps = 0.02;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_box(size=[10,10,10], r=0.5) {
    // Robust rounded box via hull of spheres; r clamped to avoid inversion
    sx = size[0]; sy = size[1]; sz = size[2];
    rr = clamp(r, 0, min(sx, min(sy, sz))/2 - eps);

    if (rr <= 0) {
        cube(size, center=true);
    } else {
        hull() {
            for (x = [-1, 1], y = [-1, 1], z = [-1, 1])
                translate([x*(sx/2-rr), y*(sy/2-rr), z*(sz/2-rr)])
                    sphere(r=rr);
        }
    }
}

module rail_solid() {
    // Base rail body with rounded edges
    rounded_box([rail_width, rail_length, rail_height], r=edge_round);
}

module rail_details_cut() {
    // Side raceway grooves (longitudinal)
    // Cut from both sides; ensure they intersect the body (no floating)
    groove_h = min(side_groove_height, rail_height - 2*eps);
    groove_d = clamp(side_groove_depth, 0, rail_width/2 - eps);

    for (sx = [-1, 1]) {
        translate([sx*(rail_width/2 - groove_d/2 + eps), 0, side_groove_z])
            cube([groove_d + 2*eps, rail_length + 2*eps, groove_h], center=true);
    }

    // Top relief channel (longitudinal)
    trw = clamp(top_relief_width, 0, rail_width - 2*eps);
    trd = clamp(top_relief_depth, 0, rail_height/2 - eps);
    if (trd > 0 && trw > 0) {
        translate([0, 0, rail_height/2 - trd/2 + eps])
            cube([trw, rail_length + 2*eps, trd + 2*eps], center=true);
    }

    // Bottom relief channel (longitudinal)
    brw = clamp(bottom_relief_width, 0, rail_width - 2*eps);
    brd = clamp(bottom_relief_depth, 0, rail_height/2 - eps);
    if (brd > 0 && brw > 0) {
        translate([0, 0, -rail_height/2 + brd/2 - eps])
            cube([brw, rail_length + 2*eps, brd + 2*eps], center=true);
    }
}

module mounting_holes_cut() {
    // Through holes along length (Y axis), drilled from top (Z+)
    // Use formulas only; ensure valid spacing when hole_count==1/2+
    usable = rail_length - 2*hole_edge_margin;
    step = (hole_count > 1) ? (usable/(hole_count-1)) : 0;

    for (i = [0:hole_count-1]) {
        y = -rail_length/2 + hole_edge_margin + i*step;

        // Through hole (along Z)
        translate([0, y, 0])
            cylinder(h=rail_height + 2*eps, r=hole_diameter/2, center=true);

        // Counterbore from top
        cbd = clamp(counterbore_depth, 0, rail_height - eps);
        if (cbd > 0) {
            translate([0, y, rail_height/2 - cbd/2 + eps])
                cylinder(h=cbd + 2*eps, r=counterbore_diameter/2, center=true);
        }
    }
}

module complete_model() {
    // One connected solid: base minus grooves and holes
    difference() {
        rail_solid();
        rail_details_cut();
        mounting_holes_cut();
    }
}

// Final Output
complete_model();