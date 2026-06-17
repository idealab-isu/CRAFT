$fn = 128;

// Standoff pillar parameters
thread_d = 3.0;        // mm (M3 nominal major diameter)
length   = 20.0;       // mm overall length

// "Nonemm diameter" is unspecified; use a reasonable default for an M3 standoff body
outer_d  = 6.0;        // mm body diameter (fallback)

// Thread parameters (visual/printable approximation)
pitch        = 0.5;    // mm (M3 coarse)
thread_depth = 0.35;   // mm radial depth of thread profile
clearance    = 0.15;   // mm radial clearance for internal thread fit

// Small lead-in chamfers to make it look/print like a real standoff
chamfer_h = 0.6;       // mm
chamfer_w = 0.4;       // mm (radial)

eps = 0.02;

module internal_thread_cut(h, major_d, pitch, depth, clearance) {
    turns = h / pitch;

    // Minor diameter for the bore (kept slightly generous for fit)
    minor_d = major_d - 2*depth + 2*clearance;

    // Base through-bore
    cylinder(h = h + 2*eps, d = minor_d, center = false);

    // Helical groove cut (triangular profile twisted around axis)
    translate([0, 0, -eps])
        linear_extrude(
            height = h + 2*eps,
            twist  = 360*turns,
            slices = max(ceil(turns*60), 120),
            center = false
        )
            translate([major_d/2 - depth/2 + clearance, 0, 0])
                polygon(points=[
                    [-depth/2, -pitch*0.28],
                    [ depth/2,  0],
                    [-depth/2,  pitch*0.28]
                ]);
}

module standoff_body(h, d, chamfer_h, chamfer_w) {
    // One connected solid with small end chamfers
    union() {
        // Main cylinder shortened to make room for chamfers
        translate([0, 0, chamfer_h])
            cylinder(h = max(h - 2*chamfer_h, 0), d = d, center = false);

        // Bottom chamfer
        cylinder(h = chamfer_h, d1 = d - 2*chamfer_w, d2 = d, center = false);

        // Top chamfer
        translate([0, 0, h - chamfer_h])
            cylinder(h = chamfer_h, d1 = d, d2 = d - 2*chamfer_w, center = false);
    }
}

difference() {
    // Outer standoff pillar (connected solid)
    standoff_body(length, outer_d, chamfer_h, chamfer_w);

    // Internal M3 threaded through-hole (connected subtraction)
    internal_thread_cut(length, thread_d, pitch, thread_depth, clearance);
}