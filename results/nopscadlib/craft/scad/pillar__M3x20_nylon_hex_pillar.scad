// Standoff pillar: internal M3 thread, 20mm long, cylindrical body
// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 20.0; //[10.0:40.0:0.5]
outer_diameter_mm = 8.0; //[4.0:16.0:0.5]
hole_clearance_mm = 0.2; //[0.0:0.6:0.05]
overlap_mm = 0.6; //[0.2:2.0:0.1]

// Thread parameters (ISO metric coarse defaults)
thread_pitch_mm = 0.5;          // M3 coarse pitch
thread_depth_mm = 0.30;         // radial depth of internal thread profile (visual/printable)
thread_fn = 128;                // smoothness for cylinders
thread_slices_per_turn = 32;    // helix resolution

// Internal thread cutter (approximate helical groove) - SINGLE connected cutter solid
module internal_thread_cutter(d_nom, pitch, len, clearance=0, depth=0.30) {
    d_minor = d_nom - 2*depth;                 // approximate minor diameter for internal thread
    r_minor = max(0.01, (d_minor + clearance)/2);
    r_major = (d_nom + clearance)/2;

    turns = len / pitch;
    twist_deg = -360 * turns;                  // negative for internal thread direction
    slices = max(ceil(turns * thread_slices_per_turn), 24);

    // Union into one cutter so difference() subtracts correctly
    union() {
        // Helical groove cutter
        linear_extrude(height=len, twist=twist_deg, slices=slices, center=true, convexity=10)
            translate([r_major - depth/2, 0, 0])
                square([depth, pitch*0.60], center=true);

        // Through-hole core (minor diameter) to ensure a clear bore
        cylinder(r=r_minor, h=len + 2*overlap_mm, center=true, $fn=thread_fn);
    }
}

// Standoff body (solid)
module standoff_body() {
    cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=thread_fn);
}

// Final part: one connected solid with internal M3 thread
module standoff() {
    difference() {
        standoff_body();

        // Threaded bore cutter: extend slightly beyond ends to guarantee clean subtraction
        internal_thread_cutter(
            d_nom = thread_diameter_mm,
            pitch = thread_pitch_mm,
            len = length_mm + 2*overlap_mm,
            clearance = hole_clearance_mm,
            depth = thread_depth_mm
        );
    }
}

standoff();