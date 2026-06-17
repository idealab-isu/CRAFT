// Dimension-calibrated (target: 0.11 x 0.21 x 0.10 mm)
scale([0.995349, 1.066667, 1.746032])
{
// Keyed shaft/handle assembly - ONE connected solid
// Units: mm

$fn = 64;

// ---------------- Parameters ----------------
bbox_L = 0.21;
bbox_W = 0.11;
bbox_H = 0.10;

rod_L = bbox_L;
rod_d = 0.030;

rod_twist_deg = 70;     // stronger twist so faceting reads clearly
rod_facets = 8;
rod_slices = 64;

block_L = 0.060;
block_W = 0.090;
block_H = 0.080;
block_end_margin = 0.005;
block_chamfer = 0.006;  // more visible chamfer

knob1_d = 0.055;
knob1_len = 0.030;
knob1_pos_x = 0.070;    // along rod from left end

knob2_d = 0.045;
knob2_len = 0.028;
knob2_pos_x = 0.145;    // farther along rod

knob_facets = 8;

// Connectivity overlap (kept small relative to tiny model)
overlap = 0.0015;

rod_irreg_amp = 0.0022;

// ---------------- Helpers ----------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module oct_prism(d, len, facets=8) {
    // Axis along X (because we rotate cylinder)
    rotate([0,90,0])
        cylinder(h=len, r=d/2, center=true, $fn=facets);
}

module chamfered_block(size=[10,10,10], chamfer=1) {
    // Chamfer vertical edges (along Z) by subtracting 4 corner columns
    L = size[0]; W = size[1]; H = size[2];
    c = clamp(chamfer, 0, min(W,H)/2 - 1e-6);

    difference() {
        cube([L,W,H], center=true);

        // remove 4 vertical edge strips to create chamfered look
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(L/2 - c/2), sy*(W/2 - c/2), 0])
                cube([c, c, H + 2*overlap], center=true);
        }
    }
}

module faceted_twisted_rod() {
    // Twisted faceted rod with subtle connected irregularities
    union() {
        linear_extrude(height=rod_L, center=true, twist=rod_twist_deg,
                       slices=rod_slices, convexity=10)
            circle(r=rod_d/2, $fn=rod_facets);

        // Irregular bumps (kept small, but visible)
        for (i = [0:4]) {
            t = (i+1)/6;
            zpos = (-rod_L/2) + t*rod_L;
            sgn1 = (i%2==0) ? 1 : -1;
            sgn2 = (i%3==0) ? 1 : -1;
            translate([sgn1*(rod_d/2 - rod_irreg_amp*0.6), sgn2*(rod_d/3), zpos])
                sphere(r=rod_irreg_amp, $fn=24);
        }
    }
}

// ---------------- Assembly ----------------
module assembly_union() {
    // Build along Z then rotate so final rod axis is X
    rotate([0,90,0]) {
        union() {
            // Main rod
            faceted_twisted_rod();

            // Main block near one end (connected with overlap)
            block_center_z = (-rod_L/2) + block_end_margin + block_L/2;
            translate([0, 0, block_center_z])
                chamfered_block([block_L + 2*overlap, block_W, block_H], block_chamfer);

            // --- Knobs: TWO separate faceted polyhedral knobs, clearly distinct ---
            // Place knobs by their centers along the rod axis (Z in this build orientation).
            knob1_center_z = (-rod_L/2) + knob1_pos_x;
            knob2_center_z = (-rod_L/2) + knob2_pos_x;

            // Keep both knobs centered on the rod so they read as mounted collars,
            // and ensure they are separated by a clear gap (not a merged thickening).
            // (Positions already ensure separation; overlap only ensures manifold union.)
            translate([0, 0, knob1_center_z])
                oct_prism(knob1_d, knob1_len + 2*overlap, knob_facets);

            translate([0, 0, knob2_center_z])
                oct_prism(knob2_d, knob2_len + 2*overlap, knob_facets);

            // Small root collars to guarantee manifold connection to the rod
            // (very thin along X, but enough to fuse surfaces robustly)
            collar_t = overlap * 3;

            translate([0, 0, knob1_center_z])
                rotate([0,90,0])
                    cylinder(h=collar_t, r=knob1_d/2, center=true, $fn=knob_facets);

            translate([0, 0, knob2_center_z])
                rotate([0,90,0])
                    cylinder(h=collar_t, r=knob2_d/2, center=true, $fn=knob_facets);
        }
    }
}

// Final Output
assembly_union();
}
