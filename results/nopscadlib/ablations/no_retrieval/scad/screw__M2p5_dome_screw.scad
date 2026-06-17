// Dome head screw (M2.5-ish) — 2.5mm shank dia, 5.35mm head dia, 1.6mm head height, 10mm long
// One connected solid, smooth dome head, visible helical thread, no side protrusions.

$fn = 96;

// -------- Parameters (mm) --------
d_nom   = 2.5;     // shank major diameter
L       = 10;      // length under head
head_d  = 5.35;    // head diameter
head_h  = 1.6;     // head height

// Thread (visual, not ISO-accurate but clearly threaded)
thread_pitch = 0.45;
thread_depth = 0.22;     // radial height of thread above core
thread_width = 0.28;     // bead diameter for thread ridge
thread_start_clear = 0.25; // unthreaded just under head

// Tip
tip_len = 0.7;     // conical tip length
tip_d2  = 0.6;     // tip end diameter

// Drive recess (simple round recess)
recess_d = 2.0;
recess_h = 0.9;

// Small overlaps to guarantee watertight unions/differences
eps = 0.02;
ov  = 0.15;

// -------- Derived --------
r_shank = d_nom/2;
r_head  = head_d/2;

// Core radius so thread ridge reaches ~d_nom
r_core  = max(0.01, r_shank - thread_depth);

// Place head bottom at z=0, head top at z=head_h, shank extends to z=-L
z_head_bot = 0;
z_head_top = head_h;
z_shank_top = z_head_bot;
z_shank_bot = -L;

// Dome: spherical cap that meets the head cylinder at z=head_h with radius head_d/2
// Choose sphere radius R >= r_head; compute center so sphere intersects plane z=head_h at radius r_head.
R_dome = max(r_head + 0.2, 3.2); // keep smooth dome; >= r_head
z_sphere_c = z_head_top - sqrt(max(0, R_dome*R_dome - r_head*r_head));

// -------- Helpers --------
module dome_head_solid() {
    // Cylinder + spherical cap, clipped to head height with a clean underside at z=0
    difference() {
        intersection() {
            union() {
                // head cylinder
                translate([0,0,(z_head_bot+z_head_top)/2])
                    cylinder(h=head_h, r=r_head, center=true);

                // dome sphere
                translate([0,0,z_sphere_c])
                    sphere(r=R_dome);
            }
            // clip to [0, head_h]
            translate([0,0,head_h/2])
                cube([head_d*2, head_d*2, head_h + 2*eps], center=true);
        }

        // drive recess from top
        translate([0,0,z_head_top - recess_h/2 + eps])
            cylinder(h=recess_h + 2*eps, r=recess_d/2, center=true);
    }
}

module shank_core() {
    // Core cylinder (minor diameter) + conical tip, connected to head at z=0
    union() {
        // core cylinder
        translate([0,0,(z_shank_bot + z_shank_top)/2])
            cylinder(h=L + ov, r=r_core, center=true);

        // conical tip at bottom
        translate([0,0,z_shank_bot + tip_len/2])
            cylinder(h=tip_len + ov, r1=r_core, r2=tip_d2/2, center=true);
    }
}

module helical_thread() {
    // Helical ridge made by linear_extrude with twist of a small circle offset from axis.
    // Starts slightly below head to avoid intersecting recess/underside.
    thread_len = max(0.01, L - tip_len - thread_start_clear);
    turns = thread_len / thread_pitch;
    twist = -360 * turns;

    // Start z for thread
    z0 = z_shank_top - thread_start_clear - thread_len;

    translate([0,0,z0])
        linear_extrude(height=thread_len + ov, twist=twist, slices=max(ceil(turns*40), 80), convexity=10)
            translate([r_core + thread_depth, 0, 0])
                circle(d=thread_width, $fn=32);
}

module screw() {
    union() {
        // Head (bottom at z=0)
        dome_head_solid();

        // Shank core (extends down)
        shank_core();

        // Thread ridge (adds visible threads)
        helical_thread();

        // Small neck blend to ensure robust connection between head and shank
        // (kept subtle; does not add side protrusions)
        translate([0,0,z_head_bot - 0.15])
            cylinder(h=0.3 + ov, r1=r_core, r2=r_shank, center=true);
    }
}

// -------- Final --------
screw();