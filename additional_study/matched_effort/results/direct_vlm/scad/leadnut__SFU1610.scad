$fn = 96;

// Overall block size (X x Y x Z)
block_x = 16.0;
block_y = 28.0;
block_z = 42.5;

// Feature parameters (generic leadscrew nut housing style)
bore_d      = 8.2;     // through bore for leadscrew/nut clearance
counter_d   = 14.0;    // front counterbore/pocket
counter_h   = 10.0;    // depth of counterbore from front face (X=0)

mount_d     = 3.4;     // mounting through holes (M3 clearance)
mount_cb_d  = 6.6;     // counterbore for screw heads
mount_cb_h  = 3.0;     // counterbore depth from front face (X=0)

// Hole layout (on YZ face, centered in X)
edge_y = 5.0;          // distance from Y edges to hole centers
edge_z = 7.0;          // distance from Z edges to hole centers

eps = 0.02;

// Derived positions
x_center = block_x/2;
y1 = edge_y;
y2 = block_y - edge_y;
z1 = edge_z;
z2 = block_z - edge_z;

// Clamp counterbore depths to avoid accidental full subtraction
counter_h_eff  = min(counter_h,  block_x - 2*eps);
mount_cb_h_eff = min(mount_cb_h, block_x - 2*eps);

difference() {
    // Main body (one connected solid)
    cube([block_x, block_y, block_z], center=false);

    // Central through bore along X (axis aligned with X)
    translate([x_center, block_y/2, block_z/2])
        rotate([0, 90, 0])
            cylinder(d=bore_d, h=block_x + 2*eps, center=true);

    // Front counterbore/pocket from X=0 face, extending into the block
    translate([0, block_y/2, block_z/2])
        rotate([0, 90, 0])
            cylinder(d=counter_d, h=counter_h_eff + eps, center=false);

    // 4 mounting through holes along X
    for (yy = [y1, y2])
        for (zz = [z1, z2])
            translate([x_center, yy, zz])
                rotate([0, 90, 0])
                    cylinder(d=mount_d, h=block_x + 2*eps, center=true);

    // Front counterbores for mounting holes from X=0 face
    for (yy = [y1, y2])
        for (zz = [z1, z2])
            translate([0, yy, zz])
                rotate([0, 90, 0])
                    cylinder(d=mount_cb_d, h=mount_cb_h_eff + eps, center=false);
}