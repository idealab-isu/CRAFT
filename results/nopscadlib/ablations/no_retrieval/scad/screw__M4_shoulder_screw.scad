$fn = 128;

// Requested dimensions (mm)
shank_d   = 5.0;   // shaft major diameter
head_d    = 9.0;   // head diameter
head_h    = 2.4;   // head height
overall_L = 10.0;  // total length (tip to top of head)

// Derived
eps       = 0.05;                 // small overlap for watertight unions/differences
shank_L   = overall_L - head_h;   // length below head (includes tip)

// Tip
tip_h     = 1.2;                  // pointed tip height (part of shank_L)
tip_r     = 0.25;                 // small truncation radius to avoid zero-radius artifacts

// Thread (true helical via linear_extrude twist)
thread_pitch = 1.0;               // mm per turn
thread_depth = 0.35;              // radial height of thread above shank core
thread_w     = 0.55;              // tangential thickness of thread ridge
thread_turns = (shank_L - tip_h) / thread_pitch;

r_major = shank_d/2;
r_core  = max(0.1, r_major - thread_depth);

// Head socket (hex)
socket_flat_d = 3.0;              // across flats (approx)
socket_h      = 1.2;

module helical_thread(len, pitch, r_base, depth, w) {
    // A thin rectangular ridge placed at radius r_base and twisted along Z.
    // Unioned with the core cylinder to form visible threads.
    linear_extrude(height=len, twist=360*len/pitch, slices=max(24, ceil(24*len/pitch)), convexity=10)
        translate([r_base, 0, 0])
            square([depth, w], center=false);
}

module screw() {
    difference() {
        union() {
            // Head: z = shank_L .. overall_L
            translate([0,0,shank_L - eps])
                cylinder(h=head_h + eps, r=head_d/2);

            // Shank core (minor diameter): z = tip_h .. shank_L
            translate([0,0,tip_h - eps])
                cylinder(h=(shank_L - tip_h) + eps, r=r_core);

            // Helical thread on shank: z = tip_h .. shank_L
            translate([0,0,tip_h])
                helical_thread(len=(shank_L - tip_h), pitch=thread_pitch, r_base=r_core, depth=thread_depth, w=thread_w);

            // Pointed tip: z = 0 .. tip_h
            cylinder(h=tip_h + eps, r1=tip_r, r2=r_core);
        }

        // Hex socket in head: cut from top down
        translate([0,0,overall_L - socket_h])
            cylinder(h=socket_h + eps, r=socket_flat_d/2, $fn=6);
    }
}

screw();