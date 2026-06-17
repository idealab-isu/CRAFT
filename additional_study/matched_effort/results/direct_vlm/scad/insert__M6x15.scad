$fn = 180;

// Threaded heat-set insert
// Critical dimensions:
// - Outer diameter: 15.0 mm
// - Length: 12.0 mm
// - Internal thread for 6.0 mm screw (modeled as helical thread form)

outer_d = 15.0;
length  = 12.0;

// M6-ish internal thread (visual/printable approximation)
thread_major_d = 6.0;     // major diameter of internal thread
thread_pitch   = 1.0;     // typical M6 coarse pitch
thread_depth   = 0.55;    // radial depth of thread cut (visual)

// End chamfers (kept within overall length)
chamfer = 0.6;

// External knurl/ridges (heat-set style)
knurl_count = 48;         // number of ridges around circumference
knurl_height = 0.45;      // radial protrusion
knurl_z_margin = chamfer + 0.4; // keep knurl away from chamfers
knurl_twist = 18;         // degrees of twist over full length (gives helical knurl feel)

// Small overlap to ensure watertight unions/differences
eps = 0.02;

module outer_shell() {
    // Base cylinder with chamfers, exact overall length
    union() {
        // Bottom chamfer: z = 0 .. chamfer
        cylinder(d1 = outer_d - 2*chamfer, d2 = outer_d, h = chamfer);

        // Main body: z = chamfer .. length-chamfer
        translate([0, 0, chamfer])
            cylinder(d = outer_d, h = length - 2*chamfer);

        // Top chamfer: z = length-chamfer .. length
        translate([0, 0, length - chamfer])
            cylinder(d1 = outer_d, d2 = outer_d - 2*chamfer, h = chamfer);
    }
}

module external_knurl() {
    // Radial array of ridges that protrude outward and are connected to the body
    knurl_h = max(0, length - 2*knurl_z_margin);
    ridge_t = 0.55; // tangential thickness of each ridge
    ridge_w = knurl_height; // radial width (protrusion)

    // Place ridges so their inner face overlaps into the base cylinder
    base_r = outer_d/2;
    overlap_in = 0.25;

    translate([0, 0, knurl_z_margin])
        linear_extrude(height = knurl_h, twist = knurl_twist, slices = 80)
            union() {
                for (i = [0:knurl_count-1]) {
                    rotate(i * 360/knurl_count)
                        translate([base_r + ridge_w/2 - overlap_in, 0, 0])
                            square([ridge_w, ridge_t], center=true);
                }
            }
}

module internal_thread_cut() {
    // Subtractive helical "V" thread cut inside the bore
    // Start with a minor bore, then subtract a twisted triangular wedge around it.
    turns = length / thread_pitch;

    // Minor diameter derived from depth (approx)
    minor_d = thread_major_d - 2*thread_depth;

    // Ensure minor_d stays positive
    minor_d_safe = max(0.5, minor_d);

    union() {
        // Base minor bore through
        translate([0, 0, -eps])
            cylinder(d = minor_d_safe, h = length + 2*eps);

        // Helical thread groove: twisted triangular profile at radius ~ minor/2
        // This creates visible internal threading.
        translate([0, 0, -eps])
            linear_extrude(height = length + 2*eps, twist = -360*turns, slices = max(60, ceil(30*turns)))
                translate([minor_d_safe/2, 0, 0])
                    polygon(points=[
                        [0, -thread_pitch*0.28],
                        [thread_depth, 0],
                        [0,  thread_pitch*0.28]
                    ]);
    }
}

module insert() {
    difference() {
        // ONE connected outer solid with knurling added
        union() {
            outer_shell();
            external_knurl();
        }

        // Subtract internal thread form (includes minor bore)
        internal_thread_cut();
    }
}

insert();