// Dimension-calibrated (target: 0.08 x 0.05 x 0.05 mm)
scale([0.760012, 0.510008, 0.510008])
{
// Stepped L-shaped block with prominent side notch + rear U-shaped fork pocket
// Bounding box: 0.1 x 0.1 x 0.1 mm
// Simplified for reliable/fast rendering (removed complex chamfer wedges)

$fn = 16;

bbox_X = 0.1;
bbox_Y = 0.1;
bbox_Z = 0.1;

// L thicknesses (legs)
legX = 0.035;   // thickness of vertical leg in X
legY = 0.035;   // thickness of horizontal leg in Y

// Step (top relief in the inner corner)
step_h = 0.03;

// Large rectangular side notch (cut through full Z)
side_notch_w  = 0.045;  // depth into X from +X side
side_notch_y  = 0.060;  // length along Y
side_notch_y0 = 0.020;  // start offset from -Y
side_notch_z  = bbox_Z + 0.01; // through all Z with margin

// Rear U-pocket (open to +Y, visible in BACK view as a forked pocket)
u_depth    = 0.040;  // pocket depth from +Y face inward
u_outer_x  = 0.070;  // overall width of pocket in X
u_outer_z  = 0.070;  // overall height of pocket in Z
u_wall     = 0.012;  // side walls thickness (fork tines)
u_floor    = 0.012;  // bottom floor thickness (in Z)
u_center_x = 0.0;
u_z0       = -bbox_Z/2; // start at bottom

eps = 0.0005;

// ---------- Main geometry ----------
module L_solid() {
    // Union of two overlapping legs
    union() {
        // horizontal leg (thin in Y)
        translate([0, -bbox_Y/2 + legY/2, 0])
            cube([bbox_X, legY, bbox_Z], center=true);

        // vertical leg (thin in X)
        translate([-bbox_X/2 + legX/2, 0, 0])
            cube([legX, bbox_Y, bbox_Z], center=true);
    }
}

module step_cut() {
    // Remove a top step in the inner corner region
    x_len = (bbox_X - legX) + 2*eps;
    y_len = (bbox_Y - legY) + 2*eps;
    z_len = step_h + 2*eps;

    translate([(-bbox_X/2 + legX) + x_len/2 - eps,
               (-bbox_Y/2 + legY) + y_len/2 - eps,
               bbox_Z/2 - z_len/2 + eps])
        cube([x_len, y_len, z_len], center=true);
}

module side_notch_cut() {
    // Side notch from +X face, through full Z
    x_len = side_notch_w + 2*eps;
    y_len = side_notch_y + 2*eps;
    z_len = side_notch_z;

    translate([bbox_X/2 - x_len/2 + eps,
               -bbox_Y/2 + side_notch_y0 + y_len/2 - eps,
               0])
        cube([x_len, y_len, z_len], center=true);
}

module rear_U_cut() {
    // U-shaped recess open to +Y: subtract inner from outer to leave two side walls + floor
    outer_x = u_outer_x;
    outer_z = u_outer_z;

    inner_x = max(outer_x - 2*u_wall, 0.001);
    inner_z = max(outer_z - u_floor, 0.001);

    y_center = bbox_Y/2 - u_depth/2 + eps;

    // Outer pocket volume
    translate([u_center_x, y_center, u_z0 + outer_z/2])
    difference() {
        cube([outer_x, u_depth + 2*eps, outer_z], center=true);

        // Inner removal (slightly longer in Y to ensure clean opening)
        translate([0, 0, (u_floor/2) + (inner_z/2)])
            cube([inner_x, u_depth + 4*eps, inner_z + 2*eps], center=true);
    }
}

module model() {
    difference() {
        L_solid();
        step_cut();
        side_notch_cut();
        rear_U_cut();
    }
}

model();
}
