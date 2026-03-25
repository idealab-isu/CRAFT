// M3 grub (set) screw with visible helical threads + hex socket + cup point
// All placements are formula-based; model is one connected solid.

// Parameters
length_mm = 6; //[3:12:1]
thread_major_d_mm = 3; //[2.5:6:0.1]
thread_pitch_mm = 0.5; //[0.35:1:0.01]
hex_socket_af_mm = 1.5; //[1.0:3.0:0.1]
hex_socket_depth_mm = 2; //[1:4:0.1]
thread_clearance_eps = 0.2; //[0.05:0.5:0.05]

// Detail controls
$fn = 96;
thread_depth_mm = 0.22;          // radial thread height (cosmetic but 3D)
thread_profile_w_mm = 0.28;      // tangential width of thread ridge
thread_steps_per_turn = 28;      // higher = smoother helix
cup_point_depth_mm = 0.45;       // cup point depth
cup_point_r_mm = 0.75;           // cup point radius

// --- Helpers ---
function clamp(x, a, b) = min(max(x, a), b);

module thread_ridge(major_r, depth, pitch, len, w, steps_per_turn) {
    // Creates a helical "ridge" by hulling small cylinders along a helix.
    // This yields a real 3D thread appearance (not just a twisted extrusion).
    turns = len / pitch;
    steps = max(8, ceil(turns * steps_per_turn));
    dz = len / steps;
    dtheta = 360 * turns / steps;

    // Ridge center radius (slightly below major radius so it fuses well)
    rr = major_r - depth * 0.55;

    for (i = [0 : steps-1]) {
        z0 = -len/2 + i*dz;
        z1 = z0 + dz;
        a0 = i*dtheta;
        a1 = (i+1)*dtheta;

        hull() {
            rotate([0,0,a0]) translate([rr,0,z0])
                cylinder(r=w/2, h=dz*1.2, center=true, $fn=18);
            rotate([0,0,a1]) translate([rr,0,z1])
                cylinder(r=w/2, h=dz*1.2, center=true, $fn=18);
        }
    }
}

module hex_socket_cut(af, depth, eps) {
    // Hex prism sized by across-flats (AF)
    r_hex = af / (2*cos(30));
    cylinder(r=r_hex, h=depth + 2*eps, center=true, $fn=6);
}

module cup_point_cut(r, depth, eps) {
    // Concave cup point: subtract a sphere segment from the end face
    // Place sphere center slightly inside the end so it forms a cup.
    translate([0,0, -depth + eps])
        sphere(r=r, $fn=64);
}

// --- Main screw ---
module screw() {
    major_r = thread_major_d_mm/2;
    // Ensure minor radius stays positive
    minor_r = max(0.2, major_r - thread_depth_mm);

    // Keep socket depth within length
    sock_depth = clamp(hex_socket_depth_mm, 0.5, length_mm - 0.5);

    // Cup point sizing safety
    cup_d = clamp(cup_point_depth_mm, 0.1, length_mm/2 - 0.2);
    cup_r = clamp(cup_point_r_mm, 0.3, major_r*0.95);

    color("DimGray")
    difference() {
        // Solid body with raised helical thread ridge fused to a minor cylinder
        union() {
            // Core (minor diameter)
            cylinder(r=minor_r, h=length_mm, center=true);

            // Raised helical ridge up to major diameter
            thread_ridge(
                major_r = major_r,
                depth   = thread_depth_mm,
                pitch   = thread_pitch_mm,
                len     = length_mm,
                w       = thread_profile_w_mm,
                steps_per_turn = thread_steps_per_turn
            );

            // Slight end chamfers (typical set screw edges)
            cham_h = min(0.35, length_mm/6);
            cham_r = min(0.25, thread_depth_mm*1.2);
            translate([0,0, length_mm/2 - cham_h/2])
                cylinder(r1=major_r, r2=major_r - cham_r, h=cham_h, center=true);
            translate([0,0,-length_mm/2 + cham_h/2])
                cylinder(r1=major_r - cham_r, r2=major_r, h=cham_h, center=true);
        }

        // Hex socket cut from the "top" end
        translate([0,0, length_mm/2 - sock_depth/2 + thread_clearance_eps])
            hex_socket_cut(hex_socket_af_mm, sock_depth, thread_clearance_eps);

        // Cup point cut from the "bottom" end
        translate([0,0, -length_mm/2 + cup_d])
            cup_point_cut(cup_r, cup_d, thread_clearance_eps);
    }
}

// Assembly
module assembly() {
    screw();
}

assembly();