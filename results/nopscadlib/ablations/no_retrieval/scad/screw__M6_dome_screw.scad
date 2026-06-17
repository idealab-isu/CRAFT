// Dome head screw with visible helical threads (single connected solid)
// Target: shank Ø6.0, length under head 10.0, head Ø10.5, head height 3.3
$fn = 128;

// -------------------- Dimensions (mm) --------------------
shank_diameter     = 6.0;
length_under_head  = 10.0;

head_diameter      = 10.5;
head_height        = 3.3;

underhead_fillet_radius = 0.6;

// Drive (simple slot)
drive_recess_width  = 4.0;
drive_recess_length = 7.0;
drive_recess_depth  = 1.6;

// Thread (simplified but helical)
thread_pitch   = 1.0;     // visual pitch
thread_depth   = 0.45;    // radial height of thread
thread_start_z = 0.6;     // unthreaded length under head
thread_end_z   = 0.8;     // unthreaded length at tip
thread_turns   = max(0, (length_under_head - thread_start_z - thread_end_z) / thread_pitch);

// Tip chamfer
tip_chamfer_len = 0.8;

// Small overlap for watertight boolean ops
eps = 0.05;

// Coordinate convention:
// z=0 at underside of head (bearing surface)
// shank extends to negative z, head extends to positive z

// -------------------- Helpers --------------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// -------------------- Geometry --------------------
module dome_head() {
    // Dome head as cylinder skirt + spherical cap, total height = head_height
    head_r = head_diameter/2;

    // Choose sphere radius to create a dome; must be >= head_r
    R = max(head_r + 0.01, 1.35*head_r);

    // Sphere center z so that sphere intersects rim at (x=head_r, z=head_height)
    zc = head_height - sqrt(max(0, R*R - head_r*head_r));
    z_top = zc + R;

    // Build 2D profile and rotate_extrude
    rotate_extrude(convexity=10)
        polygon(points=concat(
            [[0,0],[head_r,0],[head_r,head_height]],
            [for (t=[0:1:32]) let(
                a0 = acos(clamp((head_height - zc)/R, -1, 1)),
                a1 = 0,
                a  = a0 + (a1-a0)*(t/32),
                x  = R*sin(a),
                z  = zc + R*cos(a)
            ) [min(x, head_r), min(z, z_top)]],
            [[0,z_top]]
        ));
}

module underhead_fillet() {
    // Adds material to blend head underside to shank
    r_sh = shank_diameter/2;
    r_f  = underhead_fillet_radius;

    rotate_extrude(convexity=10)
        translate([r_sh + r_f, r_f, 0])
            circle(r=r_f, $fn=64);
}

module shank_core() {
    // Core cylinder slightly smaller than major diameter so thread can protrude
    core_r = shank_diameter/2 - thread_depth;
    core_r = max(core_r, shank_diameter*0.35);

    translate([0,0,-length_under_head/2])
        cylinder(h=length_under_head, r=core_r, center=true);
}

module helical_thread() {
    // Helical ridge made by linear_extrude with twist of a small rectangular profile
    // Positioned so it wraps around the shank core and reaches major diameter.
    core_r = shank_diameter/2 - thread_depth;
    core_r = max(core_r, shank_diameter*0.35);

    thread_len = max(0, length_under_head - thread_start_z - thread_end_z);

    if (thread_len > 0.01) {
        // Profile: a small rectangle at radius core_r, extruded with twist
        // Width (radial) = thread_depth, thickness (tangential) = ~pitch*0.55
        prof_radial = thread_depth;
        prof_tan    = thread_pitch * 0.55;

        // Place thread along shank: from z = -thread_start_z downwards
        z0 = -thread_start_z - thread_len; // bottom of threaded section
        translate([0,0,z0])
            linear_extrude(height=thread_len + eps, twist=360*thread_turns, slices=max(24, ceil(thread_turns*48)), convexity=10)
                translate([core_r, 0, 0])
                    square([prof_radial, prof_tan], center=false);
    }
}

module tip_chamfer_cut() {
    // Conical cut at tip to remove sharp edge
    translate([0,0,-length_under_head + tip_chamfer_len/2])
        cylinder(h=tip_chamfer_len + 2*eps, r1=shank_diameter/2 + eps, r2=0, center=true);
}

module drive_recess_cut() {
    // Slot cut from the top of the head; placed by formula from head height
    // Put the cube so its top is slightly above the dome to guarantee full cut.
    z_top_est = head_height + head_diameter/4;
    translate([0,0,z_top_est - drive_recess_depth/2])
        cube([drive_recess_length, drive_recess_width, drive_recess_depth + 2*eps], center=true);
}

module screw_solid() {
    union() {
        // Head
        dome_head();

        // Fillet under head (adds material and ensures connection)
        underhead_fillet();

        // Shank core
        shank_core();

        // Helical thread ridge (connected to shank core)
        helical_thread();
    }
}

// -------------------- Final (single connected solid) --------------------
difference() {
    screw_solid();
    tip_chamfer_cut();
    drive_recess_cut();
}