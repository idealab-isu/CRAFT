// Long rectangular prismatic block with a stepped (L-shaped) planform
// and two centered U-shaped notches cut into opposite end faces.
//
// Structural fixes applied:
// - Make the planform clearly L-shaped (union of two overlapping prisms).
// - Cut TWO centered U-shaped notches on the +/-X end faces.
//   These read as centered rectangular recesses on end views and as edge cutouts in side views.
// - All translate() values are derived from dimensions (no arbitrary offsets).
// - Use small eps overlaps for robust booleans.
// - Single connected solid (one difference of one connected union).

$fn = 64;

// -------------------- Parameters (mm) --------------------
L = 0.13;   // overall length (X)  elongated axis
W = 0.07;   // overall width  (Y)
H = 0.04;   // overall height (Z)

// L-step definition (planform): remove the (+X,+Y) corner region
step_L = 0.045; // X-length of removed corner region
step_W = 0.025; // Y-width  of removed corner region

// U-notch parameters (cut into +/-X end faces)
notch_depth  = 0.02; // depth into end face (along X)
notch_width  = 0.03; // overall notch opening width (along Y)
notch_height = 0.02; // overall notch opening height (along Z)

// Remaining material for the U profile
notch_side_wall = 0.006; // remaining side wall thickness (Y)
notch_top_wall  = 0.006; // remaining top wall thickness (Z)

eps = 0.001; // small overlap for robust booleans

// -------------------- Helpers --------------------
function clamp(v, lo, hi) = min(max(v, lo), hi);

// -------------------- Derived / clamped --------------------
step_Lc = clamp(step_L, 0, L - 2*eps);
step_Wc = clamp(step_W, 0, W - 2*eps);

notch_depth_c  = clamp(notch_depth,  0, L/2 - 2*eps);
notch_width_c  = clamp(notch_width,  0, W   - 2*eps);
notch_height_c = clamp(notch_height, 0, H   - 2*eps);

side_wall = clamp(notch_side_wall, 0, notch_width_c/2 - eps);
top_wall  = clamp(notch_top_wall,  0, notch_height_c  - eps);

// Inner slot that creates the U (opens to bottom)
inner_w = max(notch_width_c  - 2*side_wall, eps);
inner_h = max(notch_height_c - top_wall,    eps);

// -------------------- Geometry --------------------
module stepped_L_block() {
    // L-shaped planform via union of two prisms that overlap (single connected solid).
    // A) Left strip: (L - step_Lc) x W
    // B) Bottom strip: L x (W - step_Wc)
    union() {
        // A) Left strip (shifted toward -X so the removed corner is at +X)
        translate([-(step_Lc/2), 0, 0])
            cube([L - step_Lc, W, H], center=true);

        // B) Bottom strip (shifted toward -Y so the removed corner is at +Y)
        translate([0, -(step_Wc/2), 0])
            cube([L, W - step_Wc, H], center=true);
    }
}

module u_notch_cut(sign=1) {
    // sign = +1 for +X end, -1 for -X end
    // Cut a U-shaped recess into the end face:
    // - Outer pocket is removed.
    // - Inner slot is subtracted from the pocket (so it is NOT removed from the body),
    //   leaving side walls + top wall (U profile).
    x_face = sign * (L/2);
    x_ctr  = x_face - sign * (notch_depth_c/2);

    translate([x_ctr, 0, 0]) {
        difference() {
            // Outer pocket to remove (slightly extended in X for clean boolean)
            cube([notch_depth_c + 2*eps, notch_width_c, notch_height_c], center=true);

            // Inner slot (keeps side walls + top wall). Make it open to the bottom:
            // extend below the pocket bottom by eps.
            // Align inner slot top with pocket top so top_wall remains.
            z_inner_ctr = (notch_height_c/2) - (inner_h/2);

            translate([0, 0, z_inner_ctr - eps])
                cube([notch_depth_c + 4*eps, inner_w, inner_h + 4*eps], center=true);
        }
    }
}

module final_model() {
    difference() {
        stepped_L_block();

        // Two centered U-notches on opposite end faces
        u_notch_cut(+1);
        u_notch_cut(-1);
    }
}

color("Silver") final_model();