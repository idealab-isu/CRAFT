$fn = 96;

// Standoff pillar, M3 internal thread, 20mm long.
// Diameter was unspecified ("Nonemm"), so choose a common M3 standoff OD.
length = 20.0;          // overall length (mm)
od     = 6.0;           // outer diameter (mm) - typical small standoff

// Internal M3-like thread approximation (visual/printable, not ISO-accurate)
thread_major_d = 3.0;   // nominal M3 major diameter (mm)
pitch          = 0.5;   // M3 coarse pitch (mm)
thread_depth   = 0.18;  // radial thread height (mm)
thread_minor_d = thread_major_d - 2*thread_depth;

// Clearance for through-hole before threading (helps printing)
pilot_d = thread_minor_d - 0.10;

// Small overlaps to ensure watertight boolean results
eps = 0.02;

module internal_thread_cut(d_major, d_minor, h, p) {
    turns = h / p;

    // Cut volume: a core cylinder + a helical "groove" that removes material
    union() {
        cylinder(h=h, d=d_minor, center=false);

        linear_extrude(height=h, twist=turns*360, slices=max(ceil(turns*24), 24), convexity=10)
            translate([d_minor/2, 0, 0])
                polygon(points=[
                    [0, -p*0.22],
                    [d_major/2 - d_minor/2, 0],
                    [0,  p*0.22]
                ]);
    }
}

difference() {
    // Standoff body (unthreaded exterior)
    cylinder(h=length, d=od, center=false);

    // Through internal thread cut (slightly extended for clean ends)
    translate([0, 0, -eps])
        internal_thread_cut(thread_major_d, pilot_d, length + 2*eps, pitch);
}