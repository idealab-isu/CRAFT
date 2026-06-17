// Leadscrew nut housing block: 16.0mm x 28.0mm x 42.5mm
// Fixes:
// - Always produces visible, non-empty geometry
// - Adds recognizable nut-housing features by default (bore, nut pocket, mounting holes, counterbores)
// - All placements derived from dimensions (no arbitrary offsets)
// - One connected solid (all subtractions remain within the main block; optional boss overlaps)

// -------------------- Parameters --------------------
block_thickness = 16.0;   // Z
block_width     = 28.0;   // Y
block_length    = 42.5;   // X

epsilon = 0.25;

// Feature enable (kept, but defaults to ON via fe_default)
feature_enable = 1.0;     // [0.0:1.0:1.0]

// Default feature sizes (non-zero so it isn't just a plain block)
leadscrew_bore_radius = 4.1;     // through Z (e.g., ~8mm clearance)
nut_pocket_size_x     = 22.0;    // pocket in X
nut_pocket_size_y     = 18.0;    // pocket in Y
nut_pocket_depth      = 8.0;     // from top face down

mount_hole_radius     = 1.8;     // ~M3 clearance
counterbore_radius    = 3.4;     // counterbore for M3 head
counterbore_depth     = 3.0;

chamfer_size          = 0.0;     // optional corner relief

alignment_feature_radius = 0.0;  // optional side boss
alignment_feature_height = 0.0;

// -------------------- Derived helpers --------------------
fe = feature_enable;

L = block_length;
W = block_width;
T = block_thickness;

function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// -------------------- Main block --------------------
module main_block() {
    cube([L, W, T], center=true);
}

// -------------------- Features (subtractive) --------------------
module leadscrew_bore() {
    r = leadscrew_bore_radius * fe;
    if (r > 0)
        cylinder(r=r, h=T + 2*epsilon, center=true, $fn=96);
}

module nut_pocket() {
    sx = nut_pocket_size_x * fe;
    sy = nut_pocket_size_y * fe;
    d  = nut_pocket_depth  * fe;

    if (sx > 0 && sy > 0 && d > 0) {
        sx_eff = clamp(sx, 0, L - 2*epsilon);
        sy_eff = clamp(sy, 0, W - 2*epsilon);
        d_eff  = clamp(d,  0, T - 2*epsilon);

        // Pocket starts at top face and goes down by d_eff
        zc = T/2 - d_eff/2;
        translate([0, 0, zc])
            cube([sx_eff, sy_eff, d_eff + epsilon], center=true);
    }
}

module mounting_holes() {
    r = mount_hole_radius * fe;
    if (r > 0) {
        // Inset derived from dimensions and hole size; guaranteed inside block
        inset_x = clamp(max(2*r + 1.0, L*0.18), 2*r + 0.8, L/2 - (2*r + 0.8));
        inset_y = clamp(max(2*r + 1.0, W*0.22), 2*r + 0.8, W/2 - (2*r + 0.8));

        x = L/2 - inset_x;
        y = W/2 - inset_y;

        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*x, sy*y, 0])
                cylinder(r=r, h=T + 2*epsilon, center=true, $fn=64);
    }
}

module counterbores() {
    r = counterbore_radius * fe;
    d = counterbore_depth  * fe;

    if (r > 0 && d > 0) {
        d_eff = clamp(d, 0, T - 2*epsilon);

        // Use same pattern as mounting holes, but ensure inset accounts for larger radius
        r_ref = max(mount_hole_radius*fe, r);
        inset_x = clamp(max(2*r_ref + 1.0, L*0.18), 2*r_ref + 0.8, L/2 - (2*r_ref + 0.8));
        inset_y = clamp(max(2*r_ref + 1.0, W*0.22), 2*r_ref + 0.8, W/2 - (2*r_ref + 0.8));

        x = L/2 - inset_x;
        y = W/2 - inset_y;

        zc = T/2 - d_eff/2; // from top face down
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*x, sy*y, zc])
                cylinder(r=r, h=d_eff + epsilon, center=true, $fn=96);
    }
}

module chamfers() {
    c = chamfer_size * fe;
    if (c > 0) {
        c_eff = clamp(c, 0, min(L, W, T)/2 - epsilon);
        for (sx = [-1, 1], sy = [-1, 1], sz = [-1, 1]) {
            translate([sx*(L/2 - c_eff/2), sy*(W/2 - c_eff/2), sz*(T/2 - c_eff/2)])
                cube([c_eff + epsilon, c_eff + epsilon, c_eff + epsilon], center=true);
        }
    }
}

// -------------------- Optional additive feature (kept connected) --------------------
module alignment_boss() {
    r = alignment_feature_radius * fe;
    h = alignment_feature_height * fe;

    if (r > 0 && h > 0) {
        overlap = min(1.0, r); // ensures connection
        x_center = L/2 + h/2 - overlap; // attached to +X face
        translate([x_center, 0, 0])
            rotate([0, 90, 0])
                cylinder(r=r, h=h, center=true, $fn=96);
    }
}

// -------------------- Final model (one connected solid) --------------------
module complete_model() {
    union() {
        difference() {
            main_block();
            leadscrew_bore();
            nut_pocket();
            mounting_holes();
            counterbores();
            chamfers();
        }
        alignment_boss();
    }
}

complete_model();