// Compact housing with neck+tab (through-hole), side latch boss, and opposite-face recess
// Target bounding box: 1.4 x 1.0 x 2.6 mm  (X x Y x Z)

$fn = 64;

// --- Bounding box (overall) ---
bbox_X = 1.4;
bbox_Y = 1.0;
bbox_Z = 2.6;

// --- Main housing (rounded-rect) ---
housing_X = 1.00;                 // along X
housing_Y = bbox_Y;               // along Y
housing_Z = bbox_Z;               // along Z
housing_r = 0.18;                 // corner radius in XY

// --- Neck + tab (handle) on +X side ---
neck_X = 0.18;
neck_Y = 0.42;
neck_Z = bbox_Z;

tab_X  = bbox_X - housing_X - neck_X;   // ensures overall X matches bbox_X
tab_Y  = 0.70;
tab_Z  = bbox_Z;

hole_d = 0.28;
hole_from_tab_end = 0.20;          // from +X end of tab to hole center

// --- Side latch boss on +Y face (protruding) ---
latch_X = 0.30;
latch_Y = 0.18;
latch_Z = 0.35;
latch_from_housing_negX = 0.55;    // measured from housing -X end toward +X

// Make latch more "latch-like" with a small step/hook on its outer end
hook_X = 0.14;
hook_Y = 0.10;
hook_Z = 0.18;

// --- Recess notch on -Y face (shallow relief) ---
recess_X = 0.55;
recess_Y_depth = 0.14;             // shallow bite into -Y face
recess_Z = 0.55;
recess_from_housing_negX = 0.55;   // measured from housing -X end toward +X
recess_z_from_top = 0.35;          // closer to top so it reads in ortho views

// Small overlap to guarantee watertight unions/differences
eps = 0.02;

// ---------- Helpers ----------
module rounded_rect_prism_xy(size=[1,1,1], r=0.1, center=true) {
    rr = min(r, min(size[0], size[1]) / 2 - 1e-6);
    minkowski() {
        cube([size[0] - 2*rr, size[1] - 2*rr, size[2]], center=center);
        cylinder(r=rr, h=0.001, center=true);
    }
}

module housing_main() {
    rounded_rect_prism_xy([housing_X, housing_Y, housing_Z], housing_r, center=true);
}

module neck_block() {
    // Connected to housing on +X side with slight overlap
    translate([housing_X/2 + neck_X/2 - eps, 0, 0])
        cube([neck_X + 2*eps, neck_Y, neck_Z], center=true);
}

module tab_block() {
    // Connected to neck on +X side with slight overlap
    translate([housing_X/2 + neck_X + tab_X/2 - eps, 0, 0])
        rounded_rect_prism_xy(
            [tab_X + 2*eps, tab_Y, tab_Z],
            r=min(0.12, tab_Y/2 - 1e-6),
            center=true
        );
}

module hole_cut() {
    // Through-hole along Z, centered in Y, positioned from +X end of tab
    x_end  = housing_X/2 + neck_X + tab_X;     // +X end of tab (relative to origin)
    x_hole = x_end - hole_from_tab_end;
    translate([x_hole, 0, 0])
        cylinder(d=hole_d, h=bbox_Z + 2, center=true);
}

module latch_boss() {
    // Protrudes from +Y face of housing; positioned along X from housing -X end
    x0 = -housing_X/2 + latch_from_housing_negX;

    union() {
        // main boss (overlaps into housing slightly for solid connection)
        translate([x0, housing_Y/2 + latch_Y/2 - eps, 0])
            cube([latch_X, latch_Y + 2*eps, latch_Z], center=true);

        // small "hook/step" on the outer (+Y) end to read as a latch
        // placed on the boss' outer face, slightly toward +X and +Z
        translate([
            x0 + (latch_X/2 - hook_X/2) - eps,
            housing_Y/2 + latch_Y - hook_Y/2 - eps,
            (latch_Z/2 - hook_Z/2) - eps
        ])
            cube([hook_X, hook_Y + 2*eps, hook_Z], center=true);
    }
}

module recess_cut() {
    // Shallow recess into -Y face of housing (not through), clearly visible:
    // - anchored to the -Y face
    // - shifted upward in Z
    x0 = -housing_X/2 + recess_from_housing_negX;

    // Center the recess near the top (+Z) while staying inside the housing
    z0 = housing_Z/2 - recess_z_from_top - recess_Z/2;
    z0_clamped = max(-housing_Z/2 + recess_Z/2 + eps, min(housing_Z/2 - recess_Z/2 - eps, z0));

    // Place cutter so it bites into the -Y face by recess_Y_depth
    // Center of cutter is inside the housing by half the depth.
    y0 = -housing_Y/2 + recess_Y_depth/2 + eps;

    translate([x0, y0, z0_clamped])
        cube([recess_X, recess_Y_depth + 2*eps, recess_Z], center=true);
}

// ---------- Final solid ----------
difference() {
    union() {
        housing_main();
        neck_block();
        tab_block();
        latch_boss();
    }
    hole_cut();
    recess_cut();
}