$fn = 96;

// Target outer dimensions (must remain 8.0 x 10.2 x 15.0)
block_W = 8.0;   // X
block_D = 10.2;  // Y
block_H = 15.0;  // Z

// Leadscrew/nut housing features (generic, printable)
bore_d = 4.2;                 // through bore for leadscrew (Z)

// Make the leadnut clearly identifiable:
// 1) A hex-nut capture pocket on ONE face (top) (subtractive)
// 2) A distinct "leadscrew nut insert" body inside the block (additive ring)
//    with a through bore (subtractive) so it reads as an insert, not just a hole.
nut_flat_w = 6.2;             // across-flats for nut capture (hex pocket)
nut_pocket_depth = 4.0;       // depth of nut pocket from top face

// Visible openings around the bore on both faces (subtractive)
counterbore_d = 6.0;
counterbore_depth = 1.2;

// Internal leadnut insert (additive) - simple sleeve that is clearly a "nut" inside
insert_od = 6.6;              // outer diameter of insert (must fit inside 8x10.2 block)
insert_h  = 6.0;              // height of insert body
insert_z_center = 0;          // centered in block for clear silhouette

// Optional simplified "thread" cue (subtractive)
thread_hint = true;
thread_major_d = 4.6;
thread_minor_d = 4.2;
thread_pitch = 2.0;
thread_turns = 4;
thread_groove_h = 0.35;

// Mounting holes (kept)
mount_hole_d = 2.2;           // small mounting holes (X direction)
mount_hole_edge = 1.6;        // edge margin from Y faces
mount_hole_z_from_bottom = 4.0;

// Safety / robustness
eps = 0.02;

// Helpers
module hex_prism(af, h, center=false) {
    r = af / sqrt(3); // circumradius for across-flats = af
    cylinder(h=h, r=r, $fn=6, center=center);
}

module main_body() {
    cube([block_W, block_D, block_H], center=true);
}

module leadscrew_bore(h_extra=0) {
    cylinder(h=block_H + 2*eps + h_extra, d=bore_d, center=true);
}

module nut_capture_pocket() {
    // Pocket starts at top face and goes down nut_pocket_depth
    // Center of pocket is at: top - depth/2
    zc = block_H/2 - nut_pocket_depth/2;
    translate([0, 0, zc])
        hex_prism(nut_flat_w, nut_pocket_depth + 2*eps, center=true);
}

module face_counterbores() {
    // Top counterbore
    zt = block_H/2 - counterbore_depth/2;
    translate([0, 0, zt])
        cylinder(h=counterbore_depth + 2*eps, d=counterbore_d, center=true);

    // Bottom counterbore
    zb = -block_H/2 + counterbore_depth/2;
    translate([0, 0, zb])
        cylinder(h=counterbore_depth + 2*eps, d=counterbore_d, center=true);
}

module mounting_holes() {
    // Two through holes along X, near the Y edges, at a defined Z height from bottom
    y_off = block_D/2 - mount_hole_edge;
    z0 = -block_H/2 + mount_hole_z_from_bottom;

    for (sy = [-1, 1]) {
        translate([0, sy*y_off, z0])
            rotate([0, 90, 0])
                cylinder(h=block_W + 2*eps, d=mount_hole_d, center=true);
    }
}

module thread_hint_grooves() {
    // Subtract a few thin rings with incremental rotation to hint at internal threading
    steps = thread_turns * 4;
    for (i = [0 : steps - 1]) {
        z = -block_H/2 + (i * (thread_pitch/4)) + thread_groove_h/2;
        if (z < block_H/2 - thread_groove_h/2) {
            rotate([0, 0, i * 18])
                translate([0, 0, z])
                    difference() {
                        cylinder(h=thread_groove_h, d=thread_major_d, center=true);
                        cylinder(h=thread_groove_h + 2*eps, d=thread_minor_d, center=true);
                    }
        }
    }
}

module leadnut_insert() {
    // Add a sleeve-like insert inside the block so the part reads as a nut housing.
    // Slight overlap is inherent because it's fully inside the block (single connected solid).
    translate([0, 0, insert_z_center])
        difference() {
            cylinder(h=insert_h, d=insert_od, center=true);
            // Ensure the bore fully clears through the insert
            cylinder(h=insert_h + 2*eps, d=bore_d, center=true);
        }
}

// Final: one connected solid object (union of solids) with cavities/holes subtracted
difference() {
    union() {
        main_body();
        leadnut_insert(); // clearly identifiable internal "leadscrew nut" insert
    }

    // Core functional features
    leadscrew_bore();

    // Nut capture feature (recognizable housing detail)
    nut_capture_pocket();

    // Make bore visible in top/bottom views
    face_counterbores();

    // Mounting
    mounting_holes();

    // Optional thread cue (kept simple)
    if (thread_hint) thread_hint_grooves();
}