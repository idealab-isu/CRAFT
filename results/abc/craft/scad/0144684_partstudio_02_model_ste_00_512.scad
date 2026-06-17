// Dimension-calibrated (target: 0.08 x 0.05 x 0.05 mm)
scale([0.760000, 0.510000, 0.510000])
{
// Prismatic stepped L-shaped block with large side notch + rear U-pocket (forked), with chamfers
// Bounding box enforced: 0.1 x 0.1 x 0.1 mm

$fn = 48;

// ---------- Global ----------
bbox = [0.1, 0.1, 0.1];   // X,Y,Z (mm)
eps  = 0.0005;           // small overlap to avoid coincident faces

X = bbox[0];
Y = bbox[1];
Z = bbox[2];

// ---------- Primary proportions (kept within bbox) ----------
leg_w = 0.045;           // X thickness of vertical leg
arm_d = 0.040;           // Y thickness of horizontal arm

// Step feature (small ledge on the inside corner)
step_w = 0.018;          // X extent
step_d = 0.018;          // Y extent
step_h = 0.030;          // Z extent

// Side rectangular notch (large cutout on one side) - cut from +Y side
notch_w = 0.040;         // X
notch_d = 0.030;         // Y depth from +Y
notch_h = 0.060;         // Z
notch_x0 = 0.020;        // start X from -X face
notch_z0 = 0.020;        // start Z from -Z face

// Rear U-shaped recess (visible from back, forked pocket) - open to -Y
u_w    = 0.060;          // X overall pocket width
u_d    = 0.030;          // Y depth from -Y face
u_h    = 0.060;          // Z height
u_x0   = 0.015;          // start X from -X face
u_z0   = 0.020;          // start Z from -Z face
u_wall = 0.010;          // side wall thickness (fork tines)
u_floor= 0.010;          // bottom thickness inside pocket

// Chamfers
ch_ext = 0.006;          // external chamfer size
ch_int = 0.006;          // internal chamfer size

// ---------- Helpers ----------
module chamfer_wedge_Z(size, zspan, corner=[1,1]) {
    // corner: [sx,sy] where sx,sy are +1 or -1 indicating which XY corner
    sx = corner[0];
    sy = corner[1];
    linear_extrude(height=zspan, center=true)
        polygon(points=[
            [0,0],
            [sx*size,0],
            [0,sy*size]
        ]);
}

module chamfer_wedge_X(size, xspan, corner=[1,1]) {
    // corner: [sy,sz] in YZ plane
    sy = corner[0];
    sz = corner[1];
    rotate([0,90,0])
        linear_extrude(height=xspan, center=true)
            polygon(points=[
                [0,0],
                [sy*size,0],
                [0,sz*size]
            ]);
}

// ---------- Base solid (connected) ----------
module base_L() {
    union() {
        // Vertical leg: X in [-X/2, -X/2+leg_w], full Y, full Z
        translate([-X/2 + leg_w/2, 0, 0])
            cube([leg_w, Y, Z], center=true);

        // Horizontal arm: full X, Y in [-Y/2, -Y/2+arm_d], full Z
        translate([0, -Y/2 + arm_d/2, 0])
            cube([X, arm_d, Z], center=true);

        // Step/ledge near inside corner (adds a small boss)
        // Ensure it actually intersects both leg and arm with a tiny overlap (eps)
        translate([
            (-X/2 + leg_w) + step_w/2 - eps,
            (-Y/2 + arm_d) + step_d/2 - eps,
            -Z/2 + step_h/2
        ])
            cube([step_w + 2*eps, step_d + 2*eps, step_h], center=true);
    }
}

// ---------- Cuts ----------
module side_notch_cut() {
    // Cut from +Y side into the part (clearly side-opening)
    // Place so its +Y face is slightly beyond +Y/2 to guarantee opening.
    translate([
        -X/2 + notch_x0 + notch_w/2,
        (Y/2) - (notch_d/2) + eps,
        -Z/2 + notch_z0 + notch_h/2
    ])
        cube([notch_w, notch_d + 2*eps, notch_h], center=true);
}

module rear_U_fork_cut() {
    // Create a forked U-pocket open to -Y by subtracting:
    // 1) an outer pocket volume (opens to -Y)
    // 2) an inner slot volume (leaves two tines + a floor)
    x_c = -X/2 + u_x0 + u_w/2;
    y_c = -Y/2 + u_d/2 - eps;   // pushes slightly out of -Y face to ensure opening
    z_c = -Z/2 + u_z0 + u_h/2;

    // Outer pocket volume
    translate([x_c, y_c, z_c])
        cube([u_w, u_d + 2*eps, u_h], center=true);

    // Inner slot (removes center, leaving fork tines and floor)
    // Make it slightly deeper to avoid coplanar faces with outer pocket.
    translate([x_c, y_c - eps, z_c + u_floor/2])
        cube([u_w - 2*u_wall, u_d + 4*eps, u_h - u_floor], center=true);
}

module internal_chamfer_cut() {
    // Chamfer an internal corner of the inner slot (machined detail).
    // Target: inside top-back corner of the inner slot (open side is -Y),
    // so chamfer at Y = (-Y/2 + u_d) and Z = (-Z/2 + u_z0 + u_h).
    xspan = (u_w - 2*u_wall) + 2*eps;

    x_c    = -X/2 + u_x0 + u_w/2;
    y_back = (-Y/2 + u_d) - eps;          // back wall of pocket (inside)
    z_top  = (-Z/2 + u_z0 + u_h) - eps;   // top of pocket

    translate([x_c, y_back, z_top])
        chamfer_wedge_X(ch_int, xspan, corner=[-1,-1]);
}

module external_chamfers_cut() {
    zspan = Z + 2*eps;

    // XY vertical edge breaks (all four outer corners)
    translate([ X/2,  Y/2, 0]) chamfer_wedge_Z(ch_ext, zspan, corner=[-1,-1]);
    translate([-X/2,  Y/2, 0]) chamfer_wedge_Z(ch_ext, zspan, corner=[ 1,-1]);
    translate([ X/2, -Y/2, 0]) chamfer_wedge_Z(ch_ext, zspan, corner=[-1, 1]);
    translate([-X/2, -Y/2, 0]) chamfer_wedge_Z(ch_ext, zspan, corner=[ 1, 1]);
}

module top_edge_break_cut() {
    // Break along top front edge (Y = +Y/2, Z = +Z/2), spanning full X
    xspan = X + 2*eps;
    translate([0, Y/2, Z/2])
        chamfer_wedge_X(ch_ext, xspan, corner=[-1,-1]);
}

// ---------- Final model ----------
difference() {
    base_L();

    // Primary cuts (side notch + rear forked U-pocket)
    side_notch_cut();
    rear_U_fork_cut();

    // Chamfers
    internal_chamfer_cut();
    external_chamfers_cut();
    top_edge_break_cut();
}
}
