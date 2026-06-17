// Standoff pillar with M3 (3.0mm) internal thread, 20.0mm long
// Outer diameter was unspecified ("None") -> set a reasonable default, adjustable.
$fn = 128;

// ---------------- Parameters ----------------
length = 20.0;                 // overall length (mm)
outer_diameter = 6.0;          // standoff OD (mm) - adjustable
thread_nominal_d = 3.0;        // M3 nominal major diameter (mm)
thread_pitch = 0.5;            // M3 coarse pitch (mm)
thread_depth = 0.30;           // radial depth of internal thread groove (mm) (visual/printable)
starts = 1;                    // single-start thread

eps = 0.02;

// ------------- Internal thread cutter -------------
// Creates a THROUGH hole with a helical groove cut into the wall.
// This is an approximation (not ISO-perfect), but produces visible threading.
module internal_thread_cut(d_nom, pitch, depth, len, n_starts=1) {
    turns = len / pitch;
    slices = max(ceil(turns * 40), 200);

    // Minor diameter for the base hole (approx.)
    d_minor = d_nom - 2*depth;

    // Ensure the groove doesn't exceed the available wall
    d_minor = max(d_minor, 0.1);

    union() {
        // Base through-hole
        translate([0,0,-len/2])
            cylinder(h=len, d=d_minor, center=false);

        // Helical groove(s) that widen the hole locally to form thread relief
        for (s = [0:n_starts-1]) {
            rotate([0,0, s*360/n_starts])
                translate([0,0,-len/2])
                    linear_extrude(
                        height=len,
                        twist=turns*360,
                        slices=slices,
                        center=false,
                        convexity=10
                    )
                        // Place the groove at the hole wall
                        translate([d_minor/2, 0, 0])
                            // A small "tooth" that gets subtracted from the wall
                            polygon(points=[
                                [0, -pitch*0.35],
                                [depth, 0],
                                [0,  pitch*0.35]
                            ]);
        }
    }
}

// ---------------- Main standoff ----------------
module standoff() {
    difference() {
        // Solid pillar (one connected solid)
        cylinder(h=length, d=outer_diameter, center=true);

        // Threaded through-hole (centered; length extended slightly to guarantee cut-through)
        internal_thread_cut(
            d_nom=thread_nominal_d,
            pitch=thread_pitch,
            depth=thread_depth,
            len=length + 2*eps,
            n_starts=starts
        );
    }
}

standoff();