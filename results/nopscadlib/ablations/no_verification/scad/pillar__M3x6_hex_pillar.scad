// Standoff pillar: M3 internal thread (approximated), 6.0mm long, OD parameterized
thread_diameter_mm = 3.0;   // M3 nominal
length_mm          = 6.0;
outer_diameter_mm  = 6.0;   // set as needed (request had unspecified "Nonemm")

// Thread modeling controls (visual/printable approximation)
pitch_mm        = 0.5;   // M3 coarse pitch
thread_depth_mm = 0.25;  // radial depth of internal thread groove
hole_extra_mm   = 0.15;  // clearance for printing
overlap_mm      = 0.25;  // boolean overlap

$fn = 128;

module internal_thread_cut(d_nom, pitch, len, depth, clearance) {
    r_major = (d_nom + clearance)/2;
    r_minor = max(r_major - depth, 0.01);

    // Ensure the cut fully passes through the body
    cut_h = len + 2*overlap_mm;
    turns = cut_h / pitch;

    union() {
        // Pilot hole (minor diameter) through
        cylinder(h=cut_h, r=r_minor, center=true);

        // Helical groove to suggest thread flanks (subtracted from the pilot hole)
        translate([0, 0, -cut_h/2])
            linear_extrude(height=cut_h, twist=360*turns, slices=max(ceil(turns*80), 120))
                translate([r_minor, 0, 0])
                    polygon(points=[
                        [0, -pitch*0.30],
                        [depth, 0],
                        [0,  pitch*0.30]
                    ]);
    }
}

module standoff_pillar() {
    // Basic sanity: keep wall thickness > 0
    min_od = thread_diameter_mm + 2*(thread_depth_mm + hole_extra_mm) + 0.6;
    od = max(outer_diameter_mm, min_od);

    difference() {
        // Outer body (single connected solid)
        cylinder(h=length_mm, r=od/2, center=true);

        // Internal threaded bore (through-hole)
        internal_thread_cut(
            d_nom=thread_diameter_mm,
            pitch=pitch_mm,
            len=length_mm,
            depth=thread_depth_mm,
            clearance=hole_extra_mm
        );
    }
}

standoff_pillar();