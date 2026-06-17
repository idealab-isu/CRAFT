// Dome head screw (button/dome head) with helical threads
// Target: shank Ø3.0, head Ø5.7, head height 1.65, overall length 10.0
// Coordinate system: tip at z=0, underside of head at z=shank_L, top of head at z=screw_L

$fn = 128;

// Parameters
shank_d = 3.0;          // mm (major diameter over threads)
screw_L = 10.0;         // mm (overall length, tip to top of head)
head_d  = 5.7;          // mm
head_h  = 1.65;         // mm

thread_pitch   = 0.5;   // mm
thread_depth   = 0.18;  // mm (radial)
thread_L       = 8.0;   // mm (threaded length from tip upward)
runout_L       = 1.0;   // mm (unthreaded near head)
tip_chamfer_h  = 0.6;   // mm

drive_d     = 2.0;      // mm
drive_depth = 1.0;      // mm

overlap = 0.05;         // mm small overlap to ensure watertight unions

// Derived
shank_r = shank_d/2;
head_r  = head_d/2;

shank_L = screw_L - head_h;                 // length under head (tip to underside of head)
thread_L_eff = min(thread_L, max(0, shank_L - runout_L));
unthread_L = max(0, shank_L - thread_L_eff);

// --- Geometry helpers ---

// Smooth dome head as a spherical cap of height head_h and base radius head_r
// Underside plane at z=0 for this module; top at z=head_h
module dome_head_cap() {
    h = head_h;
    a = head_r;

    // Sphere radius for cap: R = (a^2 + h^2) / (2h)
    R  = (a*a + h*h) / (2*h);
    zc = h - R; // sphere center relative to underside plane

    intersection() {
        translate([0,0,zc]) sphere(r=R);
        // keep only 0..h
        translate([0,0,h/2]) cube([2*head_d, 2*head_d, h], center=true);
    }
}

// Helical thread as a swept triangular ridge around the shank
module helical_thread(len, pitch, major_r, depth) {
    turns = len / pitch;
    linear_extrude(height=len, twist=turns*360,
                   slices=max(ceil(turns*48), 80), convexity=10)
        polygon(points=[
            [major_r - depth, -pitch*0.25],
            [major_r,          0],
            [major_r - depth,  pitch*0.25]
        ]);
}

// --- Main model ---

module screw_solid() {
    minor_r = max(0.01, shank_r - thread_depth);

    union() {
        // Shank core (minor diameter) from tip to underside of head
        cylinder(h=shank_L + overlap, r=minor_r);

        // Tip chamfer on core at z=0
        cylinder(h=tip_chamfer_h, r1=minor_r, r2=0);

        // Threads from tip upward for thread_L_eff
        if (thread_L_eff > 0)
            helical_thread(thread_L_eff + overlap, thread_pitch, shank_r, thread_depth);

        // Unthreaded runout section near head at major diameter
        if (unthread_L > 0)
            translate([0,0,thread_L_eff - overlap])
                cylinder(h=unthread_L + 2*overlap, r=shank_r);

        // Head: underside at z=shank_L, top at z=screw_L
        // Add a thin cylindrical collar at the underside to guarantee a clean, connected interface
        translate([0,0,shank_L - overlap])
            cylinder(h=overlap*2, r=head_r);

        translate([0,0,shank_L])
            dome_head_cap();
    }
}

module drive_recess() {
    // Cylindrical recess from head top down by drive_depth
    translate([0,0,screw_L - drive_depth - overlap])
        cylinder(h=drive_depth + 2*overlap, r=drive_d/2);
}

difference() {
    screw_solid();
    drive_recess();
}