// U-shaped retaining clip/bracket with rounded back, open mouth, CLEAR side through-holes, and top-front lips
// Bounding box target (approx, after outer fillet): X x Y x Z = 22.1 x 24.3 x 79.0 mm

// ---------- Parameters ----------
L = 79.0;          // length (Z)
W = 22.15;         // width (X)
D = 24.3;          // depth (Y)

wall_t = 2.2;      // wall thickness
channel_w = 14.0;  // inner channel width (X)
channel_d = 16.0;  // inner channel depth (Y)
mouth_gap = 14.0;  // open mouth width at front (X)

back_round_r = 10.5;   // outer back rounding radius (in XY)
back_flat_depth = 0.8; // small flat on very back (optional)

hole_d = 4.2;      // side hole diameter
hole_z = 39.5;     // hole center height from bottom (mm)

lip_len = 3.0;     // lip length along Y (front)
lip_thk = 1.2;     // lip thickness (Z)
lip_drop = 2.0;    // lip drop from top (Z)

outer_fillet_r = 2.5;  // outer perimeter fillet
inner_fillet_r = 1.2;  // inner channel fillet

mouth_chamfer = 1.0;   // small lead-in at mouth
hole_chamfer = 0.6;    // small countersink-ish chamfer

eps = 0.25;
overlap = 1.2;          // intentional overlap for robust unions/cuts
$fn = 64;

// ---------- Helpers ----------
function clamp(v, a, b) = v < a ? a : (v > b ? b : v);

// Ensure channel fits inside outer
channel_w2 = clamp(channel_w, 0, W - 2*wall_t);
channel_d2 = clamp(channel_d, 0, D - 2*wall_t);
mouth_gap2  = clamp(mouth_gap,  0, W - 2*wall_t);

// Coordinate convention:
// X = left/right, Y = back(-) to front(+), Z = bottom(-) to top(+)
// Model centered at origin.

// ---------- 2D profile (rounded rectangle) ----------
module rounded_back_outer_2d() {
    r = min(back_round_r, min(W, D)/2 - 0.01);
    hull() {
        translate([ -W/2 + r, -D/2 + r ]) circle(r=r);
        translate([  W/2 - r, -D/2 + r ]) circle(r=r);
        translate([ -W/2 + r,  D/2 - r ]) circle(r=r);
        translate([  W/2 - r,  D/2 - r ]) circle(r=r);
    }
}

// ---------- Main solids/voids ----------
module outer_solid() {
    linear_extrude(height=L, center=true)
        rounded_back_outer_2d();
}

module channel_void_raw() {
    // Channel open to the front: void reaches the front face (+D/2)
    // Centered so its front face is at +D/2 (plus a tiny eps to guarantee opening)
    translate([0, D/2 - channel_d2/2 + eps/2, 0])
        cube([channel_w2, channel_d2 + eps, L + 2*eps], center=true);
}

module mouth_opening_slot() {
    // Clear open mouth across the front wall region
    front_wall = max(wall_t, (D - channel_d2)/2);
    translate([0, D/2 - front_wall/2 + eps/2, 0])
        cube([mouth_gap2, front_wall + eps, L + 2*eps], center=true);
}

module mouth_leadin_chamfer() {
    // Simple lead-in cut at the mouth
    translate([0, D/2 - mouth_chamfer/2 + eps/2, 0])
        cube([mouth_gap2, mouth_chamfer + eps, L + 2*eps], center=true);
}

module inner_fillet_channel_void() {
    // Fillet the channel edges by Minkowski on the void (then subtract)
    minkowski() {
        channel_void_raw();
        sphere(r=inner_fillet_r);
    }
}

module back_alignment_flat() {
    // Small flat on the back; ensure it actually intersects the body
    translate([0, -D/2 + back_flat_depth/2, 0])
        cube([W + 2*eps, back_flat_depth + eps, L + 2*eps], center=true);
}

module top_front_lips() {
    // Two small tabs at top-front corners, leaving the mouth gap open in the middle.
    // Add slight overlap into the main body so they fuse after filleting.
    lip_w_each = max(0, (W - mouth_gap2)/2);

    y_pos = D/2 - lip_len/2 - eps/2;
    z_pos = L/2 - lip_drop - lip_thk/2;

    // Left lip
    translate([ -mouth_gap2/2 - lip_w_each/2 + overlap/2, y_pos, z_pos ])
        cube([lip_w_each + overlap, lip_len + overlap, lip_thk], center=true);

    // Right lip
    translate([  mouth_gap2/2 + lip_w_each/2 - overlap/2, y_pos, z_pos ])
        cube([lip_w_each + overlap, lip_len + overlap, lip_thk], center=true);
}

// ---------- Holes (FIXED: one per side wall, clearly visible) ----------
module side_through_holes() {
    // Place holes through the SIDE WALLS (Y direction), one on each side (X = +/-).
    // This makes them appear as circles in left/right orthographic views.
    //
    // Hole axis: along Y. We cut two cylinders, centered in each side wall thickness.
    hole_zc = -L/2 + hole_z;

    // Side wall centerlines in X:
    // Outer half-width is W/2, inner channel half-width is channel_w2/2.
    // Side wall thickness each side = (W - channel_w2)/2.
    side_wall_t = (W - channel_w2)/2;
    x_side_center = channel_w2/2 + side_wall_t/2;

    // Put holes roughly on channel centerline in Y (looks correct and intersects both walls)
    hole_yc = D/2 - channel_d2/2;

    // Cut length: exceed full depth so it always goes through
    cut_len = D + 2*(outer_fillet_r + hole_chamfer + overlap);

    for (sx = [-1, 1]) {
        translate([ sx * x_side_center, hole_yc, hole_zc ])
            rotate([90, 0, 0])  // cylinder axis along Y
                cylinder(h=cut_len, r=hole_d/2, center=true);
    }
}

module hole_chamfers() {
    // Simple countersink-ish chamfers on the OUTER side faces (X faces),
    // aligned with the side-wall holes (axis along Y).
    hole_zc = -L/2 + hole_z;

    side_wall_t = (W - channel_w2)/2;
    x_side_center = channel_w2/2 + side_wall_t/2;
    hole_yc = D/2 - channel_d2/2;

    // Place chamfer cutters so they intersect the outer surface after filleting.
    // Use outer face location (approx) and cut inward along X.
    x_outer_face = W/2 + outer_fillet_r - hole_chamfer/2;

    for (sx = [-1, 1]) {
        translate([ sx * x_outer_face, hole_yc, hole_zc ])
            rotate([0, 90 * sx, 0])  // axis along X for the chamfer cone
                cylinder(h=hole_chamfer + 2*overlap,
                         r1=hole_d/2 + hole_chamfer,
                         r2=hole_d/2,
                         center=true);
    }
}

// ---------- Core + outer fillet ----------
module core_clip_unfilleted() {
    difference() {
        union() {
            outer_solid();
            top_front_lips();
        }

        inner_fillet_channel_void();
        mouth_opening_slot();
        mouth_leadin_chamfer();
        back_alignment_flat();
    }
}

module outer_filleted_solid() {
    // Outer fillets first; holes are cut AFTER this so they remain true through-holes.
    minkowski() {
        core_clip_unfilleted();
        sphere(r=outer_fillet_r);
    }
}

// ---------- Final ----------
difference() {
    outer_filleted_solid();
    side_through_holes();
    hole_chamfers();
}