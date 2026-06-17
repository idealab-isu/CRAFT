$fn = 128;

// Standoff pillar: 6.0mm long, 9.0mm outer diameter, M3 (3.0mm) threaded THROUGH hole
thread_d = 3.0;   // nominal thread major diameter (mm)
length   = 6.0;   // overall length (mm)
outer_d  = 9.0;   // "Nonemm" interpreted as 9mm OD

// Internal thread approximation (helical groove) for a through-hole
pitch        = 0.5;   // visible/printable pitch
thread_depth = 0.25;  // radial depth of groove
starts       = 1;
eps          = 0.02;

module internal_thread_hole(d_major, L, p, depth, nstarts=1) {
    // Base clearance hole at (approx) minor diameter, then subtract a helical groove
    d_minor = max(d_major - 2*depth, 0.1);
    turns   = L / p;

    difference() {
        // Through hole core
        translate([0,0,-eps]) cylinder(d=d_minor, h=L + 2*eps);

        // Helical groove that increases effective diameter up toward d_major
        for (s = [0:nstarts-1]) {
            rotate([0,0, s*360/nstarts])
                translate([0,0,-eps])
                    linear_extrude(height=L + 2*eps, twist=360*turns, slices=max(ceil(turns*60), 60))
                        translate([d_minor/2, -p*0.18, 0])
                            square([depth, p*0.36], center=false);
        }
    }
}

module standoff_pillar(od, L, td) {
    // Ensure hole fits inside pillar wall
    d_major = min(td, od - 1.0);

    difference() {
        // Main pillar body
        cylinder(d=od, h=L);

        // Subtract threaded through-hole (connected solid remains)
        internal_thread_hole(d_major=d_major, L=L, p=pitch, depth=thread_depth, nstarts=starts);
    }
}

standoff_pillar(outer_d, length, thread_d);