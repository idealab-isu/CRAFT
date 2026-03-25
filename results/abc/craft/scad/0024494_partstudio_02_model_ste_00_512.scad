// Dimension-calibrated (target: 0.06 x 0.01 x 0.05 mm)
scale([0.708870, 0.433351, 0.960015])
{
// U-shaped clamp/bracket with semicircular saddle cutout, forked prongs, chamfered outer facets, and end through-holes.
// All translations are derived from dimensions; model is one connected solid.

$fn = 96;

// -------------------- Parameters (mm) --------------------
body_L = 0.060;   // main body length (X)
body_W = 0.030;   // main body width  (Y)
body_H = 0.050;   // main body height (Z)

fork_len = 0.020; // prong extension length (X)
prong_W  = 0.010; // each prong width (Y)
slot_W   = 0.010; // gap between prongs (Y)
prong_H  = 0.030; // prong height (Z)

cutout_R = 0.018; // saddle radius (semi-cylindrical cut)
cutout_z = 0.026; // saddle center height from bottom (Z)

hole_d = 0.003;        // through-hole diameter
hole_end_offset = 0.008; // from each end along X

chamfer = 0.003; // heavy facet amount
overlap = 0.001; // boolean overlap

// -------------------- Derived --------------------
total_L = body_L + fork_len;

prong_center_y = (slot_W/2 + prong_W/2);
prong_center_x = body_L/2 + fork_len/2 - overlap;
prong_center_z = -body_H/2 + prong_H/2;

slot_center_x  = prong_center_x;
slot_center_z  = prong_center_z;

hole1_x = -body_L/2 + hole_end_offset;
hole2_x =  body_L/2 - hole_end_offset;

// -------------------- Helpers --------------------
module chamfered_box(size=[10,10,10], c=1) {
    // Faceted/chamfered look by subtracting 45° wedges from a box.
    // Works best with relatively large c.
    sx=size[0]; sy=size[1]; sz=size[2];
    difference() {
        cube([sx,sy,sz], center=true);

        // 12 edge chamfers (approx): subtract long rotated boxes along edges
        // Along X edges (vary Y/Z)
        for (yy=[-1,1], zz=[-1,1])
            translate([0, yy*(sy/2 - c/2), zz*(sz/2 - c/2)])
                rotate([45,0,0])
                    cube([sx+2*overlap, c*2, c*2], center=true);

        // Along Y edges (vary X/Z)
        for (xx=[-1,1], zz=[-1,1])
            translate([xx*(sx/2 - c/2), 0, zz*(sz/2 - c/2)])
                rotate([0,45,0])
                    cube([c*2, sy+2*overlap, c*2], center=true);

        // Along Z edges (vary X/Y)
        for (xx=[-1,1], yy=[-1,1])
            translate([xx*(sx/2 - c/2), yy*(sy/2 - c/2), 0])
                rotate([0,0,45])
                    cube([c*2, c*2, sz+2*overlap], center=true);
    }
}

module main_body() {
    chamfered_box([body_L, body_W, body_H], chamfer);
}

module prong_block() {
    // Prong itself is chamfered for faceted look
    chamfered_box([fork_len, prong_W, prong_H], chamfer);
}

module fork_prongs() {
    union() {
        translate([prong_center_x,  prong_center_y, prong_center_z]) prong_block();
        translate([prong_center_x, -prong_center_y, prong_center_z]) prong_block();
    }
}

module fork_slot_cut() {
    translate([slot_center_x, 0, slot_center_z])
        cube([fork_len + 2*overlap, slot_W, prong_H + 2*overlap], center=true);
}

module saddle_cut() {
    // True semicircular internal cutout: subtract a cylinder and clip to half-space.
    // Cylinder axis along Y, so top view shows a circle/arc rather than polygon.
    translate([0, 0, -body_H/2 + cutout_z])
        rotate([90,0,0])
            intersection() {
                cylinder(r=cutout_R, h=body_W + 2*overlap, center=true);
                // keep only the upper half (Z >= center) to make a semicircular "U" saddle
                translate([0,0, cutout_R/2])
                    cube([2*cutout_R + 2*overlap, body_W + 4*overlap, cutout_R + 2*overlap], center=true);
            }
}

module end_holes() {
    // Through holes along Y (appear diamond-ish in some views when chamfered body is present)
    for (xx=[hole1_x, hole2_x])
        translate([xx, 0, 0])
            rotate([90,0,0])
                cylinder(d=hole_d, h=body_W + 2*overlap, center=true);
}

// -------------------- Final --------------------
difference() {
    union() {
        main_body();
        fork_prongs();
    }
    fork_slot_cut();
    saddle_cut();
    end_holes();
}
}
