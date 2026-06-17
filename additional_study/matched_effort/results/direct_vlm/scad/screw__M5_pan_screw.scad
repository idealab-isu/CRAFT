$fn = 128;

d_shaft = 5.0;     // shank diameter
L       = 10.0;    // shank length (under head)
d_head  = 10.0;    // head diameter
h_head  = 3.95;    // head height

eps = 0.02;

// Pan head profile via rotate_extrude (gives correct side silhouette)
module pan_head(d_head, h_head) {
    r = d_head/2;

    // Tunable shape parameters (kept formula-based and within given dims)
    r_top = r * 0.92;          // slightly smaller top radius
    z_top_flat = h_head * 0.18; // small flat on top
    z_shoulder = h_head * 0.55; // where the dome transitions

    rotate_extrude(convexity=10)
        polygon(points=[
            [0, 0],
            [r, 0],
            [r, z_shoulder],
            [r_top, h_head - z_top_flat],
            [r_top, h_head],
            [0, h_head]
        ]);
}

// Simple helical thread approximation (external) using linear_extrude twist
module simple_thread(d_major, length, pitch=1.0, depth=0.35) {
    r_major = d_major/2;
    r_root  = r_major - depth;

    // Base cylinder at root diameter
    union() {
        cylinder(d=2*r_root, h=length);

        // Helical ridge
        linear_extrude(height=length, twist=360*length/pitch, slices=max(ceil(24*length/pitch), 60), convexity=10)
            translate([r_root, 0, 0])
                square([depth, pitch*0.55], center=true);
    }
}

module pan_head_screw(d_shaft, L, d_head, h_head) {
    union() {
        // Threaded shank (approximation)
        simple_thread(d_major=d_shaft, length=L, pitch=1.0, depth=0.35);

        // Head, connected exactly at z=L with slight overlap
        translate([0, 0, L - eps])
            pan_head(d_head=d_head, h_head=h_head);

        // Phillips drive recess (subtracted) to make it read as a screw
        difference() {
            // nothing; use nested difference on head by re-adding head and subtracting recess
        }
    }
}

// Apply drive recess by differencing from the whole screw
module pan_head_screw_with_drive(d_shaft, L, d_head, h_head) {
    drive_depth = h_head * 0.55;
    drive_w     = d_head * 0.18;
    drive_l     = d_head * 0.70;

    difference() {
        pan_head_screw(d_shaft, L, d_head, h_head);

        // Recess positioned from top of head downward
        translate([0, 0, L + h_head - drive_depth])
            union() {
                cube([drive_l, drive_w, drive_depth + eps], center=false);
                cube([drive_w, drive_l, drive_depth + eps], center=false);
            }
    }
}

pan_head_screw_with_drive(d_shaft, L, d_head, h_head);