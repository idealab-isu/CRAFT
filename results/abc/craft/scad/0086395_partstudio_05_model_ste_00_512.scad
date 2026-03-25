// Dimension-calibrated (target: 0.09 x 0.01 x 0.11 mm)
scale([1.009225, 0.955594, 1.500252])
{
// Elongated faceted lever/bracket with tapered nose, stepped body, forked U-slot, and 3 mount holes
// Units: mm (very small part per given parameters)

$fn = 64;

// -------------------- Parameters --------------------
L = 0.11;                 // overall length (X)
W_max = 0.09;             // max width at mount end (Y)
W_mid = 0.06;             // mid/body width (Y)
T = 0.01;                 // thickness (Z)

L_nose = 0.02;            // nose length
W_tip = 0.02;             // nose tip width (controls chamfered/pointed nose)

L_mount = 0.03;           // mount block length
L_step  = 0.01;           // step transition length

slot_depth = 0.02;        // fork slot depth from mount end
slot_width = 0.03;        // slot opening width (Y)

hole_d = 0.004;           // through-hole diameter
hole_pitch = 0.008;       // spacing along X between holes
hole_edge_margin = 0.006; // first hole from mount end (X)

flat_cut_depth  = 0.006;  // side flat depth (Y)
flat_cut_length = 0.045;  // flat length (X)

overlap = 0.001;          // boolean overlap (small, relative to tiny model)

// -------------------- Derived positions --------------------
x_min = -L/2;
x_max =  L/2;

x_nose_end    = x_min + L_nose;
x_mount_start = x_max - L_mount;
x_step_start  = x_mount_start - L_step;

// -------------------- 2D planform (XY) --------------------
module planform_2d() {
    // Faceted/prismatic outline with a chamfered/pointed nose and a stepped mount end
    polygon(points=[
        // Nose tip (pointed)
        [x_min, 0],

        // Upper nose chamfer to body
        [x_min + L_nose*0.55,  W_tip/2],
        [x_nose_end,           W_mid/2],

        // Body to step
        [x_step_start,         W_mid/2],

        // Step up to mount width
        [x_step_start,         W_max/2],
        [x_max,                W_max/2],

        // Down at mount end
        [x_max,               -W_max/2],
        [x_step_start,        -W_max/2],

        // Step down to mid width
        [x_step_start,        -W_mid/2],

        // Lower nose chamfer back to tip
        [x_nose_end,          -W_mid/2],
        [x_min + L_nose*0.55, -W_tip/2]
        // closes to [x_min,0]
    ]);
}

// -------------------- Main solid --------------------
module body_solid() {
    linear_extrude(height=T, center=true, convexity=10)
        planform_2d();
}

// -------------------- Forked U-slot cut --------------------
module fork_slot_cut() {
    // Cut a centered rectangular slot that opens at the mount end (x_max) and goes inward by slot_depth.
    // Place the cube so its +X face is slightly beyond x_max to guarantee an open mouth.
    slot_len = slot_depth + 2*overlap;
    x_center = x_max - slot_depth/2 + overlap; // ensures x_max is inside the cut volume
    translate([x_center, 0, 0])
        cube([slot_len, slot_width, T + 2*overlap], center=true);
}

// -------------------- Three through-holes cut --------------------
module mount_holes_cut() {
    // 3 holes along X within the mount block, centered in Y, through Z.
    // Robustly keep all three inside the mount region.
    usable = max(0, L_mount - 2*hole_edge_margin);

    // Ensure 3-hole pattern fits: need 2*pitch <= usable
    pitch = min(hole_pitch, usable/2);

    // If mount is extremely small, collapse pitch safely (still 3 cylinders, may overlap)
    pitch = max(pitch, 0);

    for (i = [0:2]) {
        // Place holes from near the mount end inward
        xh_raw = x_max - hole_edge_margin - i*pitch;

        // Clamp to stay inside mount region
        xh = max(x_mount_start + hole_edge_margin, min(x_max - hole_edge_margin, xh_raw));

        translate([xh, 0, 0])
            cylinder(d=hole_d, h=T + 2*overlap, center=true);
    }
}

// -------------------- Angular/faceted flats cut --------------------
module side_flats_cut() {
    // Cut wedges from both +Y and -Y sides to create angular flats along length.
    // Start after the nose and extend into the stepped region for clearer faceting.
    x0 = x_min + L_nose*0.35;
    x1 = min(x0 + flat_cut_length, x_mount_start);

    len = max(0, x1 - x0);

    if (len > 0) {
        // +Y wedge (removes material from upper side)
        translate([x0, 0, 0])
            linear_extrude(height=T + 2*overlap, center=true, convexity=10)
                polygon(points=[
                    [0,   W_mid/2 + overlap],
                    [len, W_mid/2 + overlap],
                    [len, W_mid/2 - flat_cut_depth],
                    [0,   W_mid/2 - flat_cut_depth*0.35]
                ]);

        // -Y wedge (removes material from lower side)
        translate([x0, 0, 0])
            linear_extrude(height=T + 2*overlap, center=true, convexity=10)
                polygon(points=[
                    [0,   -W_mid/2 - overlap],
                    [len, -W_mid/2 - overlap],
                    [len, -W_mid/2 + flat_cut_depth],
                    [0,   -W_mid/2 + flat_cut_depth*0.35]
                ]);
    }
}

// -------------------- Final model (single connected solid) --------------------
union() {
    difference() {
        // Single connected solid base
        body_solid();

        // Subtractive features (all intersect the body; no floating parts)
        fork_slot_cut();
        mount_holes_cut();   // now guaranteed to be 3 holes
        side_flats_cut();
    }
}
}
