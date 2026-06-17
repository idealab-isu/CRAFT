// Hex head screw (single connected solid)
// Spec: shaft Ø8.0mm, head Ø15.0mm (across flats), head height 5.65mm, length 10mm (under-head)

$fn = 128;

// Parameters
shaft_diameter_mm = 8.0;      // major diameter
head_af_mm        = 15.0;     // hex across flats
head_height_mm    = 5.65;
length_mm         = 10.0;     // under-head length
overlap_mm        = 0.25;     // overlap to ensure watertight union

// Thread (visual/geometry)
thread_pitch_mm   = 1.25;
thread_depth_mm   = 0.45;     // radial depth (keep modest to avoid self-intersections)
thread_turns      = length_mm / thread_pitch_mm;
thread_slices     = max(120, ceil(40 * thread_turns));

// Tip (simple chamfered end, not a flare)
tip_length_mm     = min(1.2, length_mm * 0.18);
tip_end_d_mm      = shaft_diameter_mm * 0.92;

// Helpers
function hex_circumradius_from_flats(af) = af / sqrt(3); // circumradius for $fn=6 cylinder

module hex_prism_af(af, h) {
    cylinder(h=h, r=hex_circumradius_from_flats(af), $fn=6, center=false);
}

module external_threaded_shaft(d, h) {
    // Create a helical ridge by sweeping a small circle around the shaft radius
    // and union it with a core cylinder. This yields visible external threads.
    core_r = d/2 - thread_depth_mm;
    ridge_r = thread_depth_mm;

    union() {
        // Core
        cylinder(h=h, r=core_r, center=false);

        // Helical ridge
        linear_extrude(height=h, twist=360*thread_turns, slices=thread_slices, center=false, convexity=10)
            translate([core_r, 0, 0])
                circle(r=ridge_r, $fn=32);
    }
}

module screw() {
    union() {
        // Head: Z = [0, head_height]
        hex_prism_af(head_af_mm, head_height_mm);

        // Threaded shank: Z = [-length, 0], overlapped into head
        translate([0, 0, -length_mm - overlap_mm])
            external_threaded_shaft(shaft_diameter_mm, length_mm + overlap_mm);

        // Tip chamfer: connected to end of shank at Z = -length
        translate([0, 0, -length_mm - tip_length_mm])
            cylinder(h=tip_length_mm + overlap_mm,
                     r1=shaft_diameter_mm/2,
                     r2=tip_end_d_mm/2,
                     center=false);
    }
}

screw();