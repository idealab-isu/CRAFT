// Standoff pillar: M3 (3.0mm) internal thread, 13.0mm long
// Outer diameter request was "Nonemm" (invalid). Provide a safe default and allow override.
$fn = 128;

// ---------------- Parameters ----------------
length = 13.0;                 // overall length (mm)
outer_diameter = 6.0;          // default OD (mm) - override as needed

thread_nominal_d = 3.0;        // M3 nominal major diameter (mm)
thread_pitch = 0.5;            // M3 coarse pitch (mm)

// Printable internal thread approximation (radial height).
// Increase slightly for more visible thread; decrease for easier fit.
thread_depth = 0.30;           // mm (radial)

// Minor diameter (tap drill-ish). Keep >= ~2.4mm for M3-ish internal thread.
thread_minor_d = max(2.4, thread_nominal_d - 2*thread_depth);

chamfer = 0.6;                 // end chamfer (mm)
eps = 0.03;                    // boolean overlap (mm)

// ---------------- Helpers ----------------
module chamfered_cylinder(h, d, c) {
    c2 = min(c, h/2 - eps);
    union() {
        cylinder(h=h - 2*c2, d=d, center=true);
        translate([0,0, (h/2 - c2/2)])
            cylinder(h=c2, d1=d, d2=d - 2*c2, center=true);
        translate([0,0, -(h/2 - c2/2)])
            cylinder(h=c2, d1=d - 2*c2, d2=d, center=true);
    }
}

// Internal thread "cutter": subtracts a helical triangular ridge from the hole wall.
// This produces visible helical grooves (approximate thread).
module internal_thread_cutter(h, minor_d, pitch, depth) {
    turns = h / pitch;
    slices = max(ceil(turns * 80), 200); // higher = smoother/more visible helix

    // Place the triangle so it cuts into the wall around the minor radius.
    // The triangle extends radially outward by 'depth' from the minor radius.
    linear_extrude(height=h + 2*eps, twist=turns*360, center=true, slices=slices, convexity=10)
        translate([minor_d/2, 0, 0])
            polygon(points=[
                [0, -pitch*0.30],
                [depth, 0],
                [0,  pitch*0.30]
            ]);
}

// ---------------- Model ----------------
module standoff_pillar() {
    // Ensure the hole + thread fits inside the body
    assert(outer_diameter > thread_nominal_d + 2*thread_depth + 0.8,
        "outer_diameter too small for M3 internal thread; increase outer_diameter.");

    difference() {
        // One connected solid body
        chamfered_cylinder(length, outer_diameter, chamfer);

        // Base through-hole at minor diameter
        cylinder(h=length + 2*eps, d=thread_minor_d, center=true);

        // Helical grooves to represent internal threading
        if (thread_depth > 0)
            internal_thread_cutter(length, thread_minor_d, thread_pitch, thread_depth);
    }
}

standoff_pillar();