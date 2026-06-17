// Threaded heat-set insert (parametric, connected solid)
// Target: 5.8mm OD, 7.1mm length, internal THREAD for 5.0mm screw (approx. ISO metric)

$fn = 128;

// ---------- Parameters ----------
od = 5.8;                 // outer diameter (mm)
L  = 7.1;                 // overall length (mm)

screw_nominal_d = 5.0;    // M5
thread_pitch = 0.8;       // M5 coarse pitch (mm)

thread_class_allow = 0.15; // (mm) enlarge internal thread slightly for print/fit

// Lead-in / counterbore (optional)
counterbore_d = 5.6;      // (mm) small lead-in
counterbore_depth = 0.8;  // (mm)

// End chamfers
chamfer_len = 0.5;        // (mm)

// Knurl approximation (rings)
knurl_ring_count = 3;
knurl_ring_height = 0.6;  // (mm)
knurl_ring_radial = 0.25; // (mm) radial protrusion beyond OD
knurl_overlap = 0.20;     // (mm) overlap into body to ensure connectivity

// Thread quality
thread_slices_per_turn = 28; // higher = smoother
eps = 0.02;

// ---------- Derived ----------
cb_depth = min(counterbore_depth, max(0, L/2 - chamfer_len));
cb_d = max(counterbore_d, screw_nominal_d + 0.2);

// Approx internal thread geometry (ISO-ish):
// Major diameter ~ nominal; minor diameter ~ d - 1.22687*p
thread_major_d = screw_nominal_d + thread_class_allow;
thread_minor_d = max(0.5, thread_major_d - 1.22687 * thread_pitch);

// ---------- Modules ----------
module body_core() {
    cylinder(h=L, d=od, center=true);
}

module knurl_rings() {
    z0 = -L/2 + chamfer_len + knurl_ring_height/2;
    z1 =  L/2 - chamfer_len - knurl_ring_height/2;
    span = max(0, z1 - z0);

    union() {
        for (i = [0:knurl_ring_count-1]) {
            z = (knurl_ring_count == 1) ? (z0 + z1)/2
                                        : (z0 + i * span/(knurl_ring_count-1));
            translate([0,0,z])
                cylinder(h=knurl_ring_height + 2*knurl_overlap,
                         d=od + 2*knurl_ring_radial,
                         center=true);
        }
    }
}

module outer_solid() {
    union() {
        body_core();
        knurl_rings();
    }
}

module end_chamfer(zsign=1) {
    translate([0,0, zsign*(L/2 - chamfer_len/2)])
        cylinder(h=chamfer_len + 2*eps,
                 d1=od + 2*knurl_ring_radial + 2*eps,
                 d2=max(0.01, od - 2*chamfer_len),
                 center=true);
}

module top_counterbore() {
    translate([0,0, L/2 - cb_depth/2])
        cylinder(h=cb_depth + 2*eps, d=cb_d, center=true);
}

// Internal thread (subtractive): helical triangular "tap" that leaves a threaded bore
module internal_thread_tap(h, major_d, minor_d, pitch) {
    turns = h / pitch;
    steps = max(12, ceil(turns * thread_slices_per_turn));
    step_h = h / steps;
    step_ang = 360 * turns / steps;

    r_maj = major_d/2;
    r_min = minor_d/2;

    // Triangular profile in XY (pointing outward), extruded along Z and twisted
    // This creates a helical ridge; subtracting it from a pre-bored cylinder yields internal threads.
    linear_extrude(height=h + 2*eps, twist=360*turns, slices=steps, center=true, convexity=10)
        polygon(points=[
            [r_min, -pitch*0.22],
            [r_maj,  0],
            [r_min,  pitch*0.22]
        ]);
}

module threaded_bore_subtractive() {
    // Base bore at minor diameter ensures a true threaded cavity after subtracting the tap
    union() {
        cylinder(h=L + 2*eps, d=thread_minor_d, center=true);
        internal_thread_tap(L + 2*eps, thread_major_d, thread_minor_d, thread_pitch);
    }
}

// ---------- Final Model ----------
difference() {
    outer_solid();

    // End chamfers
    end_chamfer(+1);
    end_chamfer(-1);

    // Internal threaded bore for M5 (approx)
    threaded_bore_subtractive();

    // Lead-in counterbore at top
    if (cb_depth > 0)
        top_counterbore();
}