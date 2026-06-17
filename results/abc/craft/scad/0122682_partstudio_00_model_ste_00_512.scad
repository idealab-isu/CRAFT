// Dimension-calibrated (target: 0.08 x 0.08 x 0.05 mm)
scale([0.881720, 0.866708, 0.576114])
{
// L-shaped right-angle mounting bracket with flange/lip, internal fillet, rounded outer corners,
// bend relief, and one through-hole in the upright leg.
// Bounding box target: 0.1 x 0.1 x 0.1 mm

$fn = 96;

// ---------------- Parameters (mm) ----------------
bbox_X = 0.10;
bbox_Y = 0.10;
bbox_Z = 0.10;

plate_t = 0.012;

base_Lx = 0.090;
base_Ly = 0.090;

upright_Lx = 0.090;
upright_Hz = 0.080;

fillet_r = 0.020;

hole_d = 0.012;
hole_center_from_top  = 0.025;  // from top edge of upright down
hole_center_from_side = 0.045;  // from left edge of upright in +X

flange_w = 0.012;
flange_t_add = 0.006;

outer_corner_r = 0.004;

bevel_L = 0.020;
bevel_depth = 0.006;

eps = 0.0005;

// Slight overlap for robust unions (scaled to this tiny model)
overlap = 0.0015; // ensures parts touch/merge

// ---------------- Helpers ----------------
module rounded_box(size=[10,10,10], r=1, center=true) {
    sx = size[0]; sy = size[1]; sz = size[2];
    rr = max(0, min(r, sx/2 - eps, sy/2 - eps, sz/2 - eps));
    hull() {
        for (x = [-1, 1], y = [-1, 1], z = [-1, 1])
            translate([x*(sx/2-rr), y*(sy/2-rr), z*(sz/2-rr)])
                sphere(r=rr);
    }
}

// ---------------- Parts ----------------
module base_plate() {
    // Base lies in XY, thickness in Z, bottom at Z=0
    translate([0, 0, plate_t/2])
        rounded_box([base_Lx, base_Ly, plate_t], r=outer_corner_r, center=true);
}

module upright_plate() {
    // Upright lies in XZ, thickness in Y.
    // Place it so its bottom sits on the base top (Z=plate_t) with overlap,
    // and its back face aligns to the base -Y edge (Y=-base_Ly/2) with overlap.
    y_center = -base_Ly/2 + (plate_t + overlap)/2;
    z_center = plate_t + upright_Hz/2 - overlap/2;

    translate([0, y_center, z_center])
        rounded_box([upright_Lx, plate_t + overlap, upright_Hz + overlap], r=outer_corner_r, center=true);
}

module internal_fillet() {
    // Large internal fillet at inside corner between:
    // - base top surface at Z=plate_t
    // - upright inner face at Y=-base_Ly/2 + plate_t
    // Create a quarter-cylinder (along X) and clip to the inside corner region.
    y0 = -base_Ly/2 + plate_t; // inside face of upright (toward +Y)
    z0 = plate_t;              // top face of base

    intersection() {
        // Cylinder along X, positioned so its tangent planes are at y=y0 and z=z0
        translate([0, y0 + fillet_r, z0 + fillet_r])
            rotate([0, 90, 0])
                cylinder(r=fillet_r, h=upright_Lx + 2*overlap, center=true);

        // Clip to the quarter region and slightly intrude into both plates for a solid merge
        translate([0, y0 + fillet_r/2 - overlap/2, z0 + fillet_r/2 - overlap/2])
            cube([upright_Lx + 2*overlap, fillet_r + overlap, fillet_r + overlap], center=true);
    }
}

module flange_lip() {
    // Thickened flange along one edge of base (positive Y edge).
    // Overlap slightly into the base so it is definitely connected.
    y_center = base_Ly/2 - (flange_w + overlap)/2;
    z_center = (plate_t + flange_t_add)/2;

    translate([0, y_center, z_center])
        rounded_box([base_Lx, flange_w + overlap, plate_t + flange_t_add], r=outer_corner_r, center=true);
}

module bend_relief_cut() {
    // Small beveled/relieved region near the bend on the inside corner.
    // Cut a rotated wedge that intersects both the base top and upright inner face.
    y0 = -base_Ly/2 + plate_t;
    z0 = plate_t;

    // Center the wedge right at the inside corner; ensure it reaches into both plates.
    translate([0, y0 + bevel_depth/2, z0 + bevel_depth/2])
        rotate([0, 0, 45])
            cube([bevel_L, bevel_depth*1.8, bevel_depth*1.8], center=true);
}

module through_hole_cut() {
    // Through-hole in upright leg (through Y thickness), explicitly located on upright.
    hole_x = -upright_Lx/2 + hole_center_from_side;
    hole_z = (plate_t + upright_Hz) - hole_center_from_top; // upright top is at plate_t+upright_Hz

    // Upright Y center matches upright_plate()
    y_center = -base_Ly/2 + (plate_t + overlap)/2;

    translate([hole_x, y_center, hole_z])
        rotate([90, 0, 0])
            cylinder(d=hole_d, h=(plate_t + overlap) + 10*eps, center=true);
}

// ---------------- Model ----------------
module bracket_solid() {
    union() {
        base_plate();
        upright_plate();
        internal_fillet();
        flange_lip();
    }
}

module complete_model() {
    difference() {
        bracket_solid();
        bend_relief_cut();
        through_hole_cut();
    }
}

// ---------------- Fit to bounding box ----------------
// Keep the part within bbox_Z by shifting in Z only (X/Y already centered).
z_max = max(plate_t + upright_Hz, plate_t + flange_t_add);
z_shift = (bbox_Z/2) - (z_max/2) - eps;

color("Silver")
translate([0, 0, z_shift])
    complete_model();
}
