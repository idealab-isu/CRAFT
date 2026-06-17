$fn = 128;

// Standoff pillar (female-female)
// Spec: M3 internal thread, 13mm long, diameter unspecified -> choose a typical OD
thread_d = 3.0;      // M3 nominal
length   = 13.0;     // overall length

outer_d  = 6.0;      // typical M3 standoff OD (set since "None mm diameter" is unspecified)
bore_d   = 2.6;      // M3 tap drill / clearance for internal thread approximation

// Internal thread approximation parameters (visual/printable)
pitch        = 0.5;  // M3 coarse pitch
thread_depth = 0.25; // radial depth of internal thread grooves (approx)
starts       = 1;

eps = 0.02;

module internal_helical_thread(d_bore, h, p, depth, nstarts=1) {
    r_bore = d_bore/2;

    // 2D "cutter" profile that will be twist-extruded and subtracted
    // It protrudes outward from the bore radius by 'depth'
    module cutter2d() {
        polygon(points=[
            [r_bore,        -p*0.22],
            [r_bore+depth,   0     ],
            [r_bore,         p*0.22]
        ]);
    }

    union() {
        // Ensure a continuous bore through the part
        cylinder(h=h + 2*eps, r=r_bore, center=false);

        // Helical groove(s) to suggest internal threading
        for (s = [0:nstarts-1]) {
            rotate([0,0, s*360/nstarts])
                linear_extrude(
                    height=h + 2*eps,
                    twist=360*(h + 2*eps)/p,
                    slices=max(ceil((h + 2*eps)*24), 120),
                    convexity=10
                )
                    cutter2d();
        }
    }
}

module standoff_pillar(od, h, bore, p, depth, nstarts=1) {
    difference() {
        // Pillar body
        cylinder(h=h, r=od/2, center=false);

        // Internal threaded bore (subtracted), aligned and slightly extended for clean cut
        translate([0,0,-eps])
            internal_helical_thread(bore, h, p, depth, nstarts);
    }
}

standoff_pillar(outer_d, length, bore_d, pitch, thread_depth, starts);