// Standoff pillar: M3 internal thread, 20mm long, diameter unspecified ("Nonemm") -> parametric default.
// One connected solid. Thread is represented by a helical V-groove cut into the bore.

$fn = 128;

// -------- Parameters --------
standoff_length = 20.0;          // mm
body_flat_d     = 6.0;           // mm across flats (unspecified -> default; change as needed)
thread_nominal  = 3.0;           // mm (M3)
thread_pitch    = 0.5;           // mm (M3 coarse)
thread_length   = 20.0;          // mm (through)
clearance       = 0.15;          // mm (internal thread clearance)
chamfer         = 0.6;           // mm end chamfer
lead_in         = 1.2;           // mm lead-in at both ends
overlap         = 0.25;          // mm boolean robustness

// Thread visual/print controls
thread_radial_depth = 0.35;      // mm radial depth of groove (visible thread)
thread_slices_per_turn = 28;     // higher = smoother

// -------- Helpers --------
module hex_prism(flat_d, h, center=true) {
    // Regular hex with given across-flats dimension
    // across-flats = 2*apothem; circumradius = flat_d / sqrt(3)
    r = flat_d / sqrt(3);
    cylinder(h=h, r=r, $fn=6, center=center);
}

module lead_in_cone(d1, d2, h, zpos) {
    translate([0, 0, zpos])
        cylinder(h=h + overlap, r1=d1/2, r2=d2/2, center=true);
}

module internal_thread_cut(d_nom, pitch, length, depth, clr=0.0) {
    // Cuts an internal thread by:
    // 1) cutting a base (minor) bore
    // 2) cutting a helical V-groove along the bore wall (visible thread)
    turns = length / pitch;
    steps = max(ceil(turns * thread_slices_per_turn), 60);

    // Approx ISO-ish internal thread:
    // minor diameter ~ d - 1.0825*p (approx), then add clearance
    d_minor = d_nom - 1.0825 * pitch + 2*clr;
    r_minor = max(0.2, d_minor/2);

    // Groove centered near the bore wall
    r_center = r_minor + depth*0.55;

    // V-groove profile (2D) in XY, then helical extrude along Z
    // Make it slightly oversized so it reliably intersects the bore wall.
    v_height = depth + 0.15;
    v_width  = pitch * 0.70;

    union() {
        // Base bore (through)
        cylinder(h=length + 2*overlap, r=r_minor, center=true);

        // Helical V-groove cutter
        translate([0, 0, -length/2 - overlap])
            linear_extrude(height=length + 2*overlap,
                           twist=turns*360,
                           slices=steps,
                           convexity=10)
                translate([r_center, 0, 0])
                    polygon(points=[
                        [-v_height, -v_width/2],
                        [ v_height,  0],
                        [-v_height,  v_width/2]
                    ]);
    }
}

// -------- Model --------
module standoff() {
    difference() {
        // Body (hex standoff)
        hex_prism(body_flat_d, standoff_length, center=true);

        // End chamfers (cuts)
        lead_in_cone(body_flat_d, body_flat_d - 2*chamfer, chamfer,
                     standoff_length/2 - chamfer/2);
        lead_in_cone(body_flat_d - 2*chamfer, body_flat_d, chamfer,
                     -standoff_length/2 + chamfer/2);

        // Threaded through-bore (cuts)
        internal_thread_cut(thread_nominal, thread_pitch, thread_length, thread_radial_depth, clearance);

        // Lead-in at both ends (cuts)
        lead_in_cone(thread_nominal + 1.2, thread_nominal + 0.2, lead_in,
                     standoff_length/2 - lead_in/2);
        lead_in_cone(thread_nominal + 0.2, thread_nominal + 1.2, lead_in,
                     -standoff_length/2 + lead_in/2);
    }
}

standoff();