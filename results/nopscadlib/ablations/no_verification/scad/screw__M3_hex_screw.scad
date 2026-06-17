// Hex head screw (single connected solid)
// Target: 3.0mm shank diameter, 6.4mm head diameter (across flats), head height 2.125mm, 10mm long (under head)

$fn = 96;

// Parameters
shaft_diameter_mm = 3.0;
overall_length_mm = 10.0;      // length under head
head_diameter_mm = 6.4;        // across flats (AF)
head_height_mm = 2.125;

threaded = 1;                  // 0/1
thread_pitch_mm = 0.5;         // visual thread pitch
thread_depth_mm = 0.18;        // visual thread depth (radial)
thread_start_offset_mm = 0.6;  // unthreaded length under head
tip_chamfer_mm = 0.35;         // small tip chamfer
overlap_mm = 0.05;

// Helpers
function hex_circumradius_from_af(af) = af / sqrt(3); // AF = sqrt(3)*R for hex polygon

module hex_head(af, h) {
    cylinder(h=h, r=hex_circumradius_from_af(af), $fn=6);
}

module threaded_shank(d, L, pitch, depth, start_offset, tip_chamfer) {
    r0 = d/2;
    r1 = r0 + depth;

    // Base shank
    union() {
        // Main cylinder
        cylinder(h=L, r=r0);

        // Tip chamfer (slight taper at end)
        if (tip_chamfer > 0)
            translate([0,0,0])
                cylinder(h=tip_chamfer, r1=r0, r2=max(0.01, r0 - tip_chamfer));

        // Simple helical thread approximation (unioned so it's one solid)
        if (threaded) {
            thread_len = max(0, L - start_offset);
            if (thread_len > 0) {
                translate([0,0,start_offset])
                    linear_extrude(height=thread_len, twist=360*thread_len/pitch, slices=max(24, ceil(thread_len/pitch)*24))
                        translate([r0, 0, 0])
                            circle(r=depth, $fn=24);
            }
        }
    }
}

module hex_head_screw() {
    // Place underside of head at z=0, shank extends to +Z
    union() {
        // Head (below z=0)
        translate([0,0,-head_height_mm])
            hex_head(head_diameter_mm, head_height_mm);

        // Shank (from z=0 to z=overall_length_mm)
        translate([0,0,0])
            threaded_shank(shaft_diameter_mm, overall_length_mm, thread_pitch_mm, thread_depth_mm, thread_start_offset_mm, tip_chamfer_mm);

        // Small fillet-like collar (tiny overlap) to ensure watertight union
        translate([0,0,-overlap_mm])
            cylinder(h=overlap_mm*2, r=shaft_diameter_mm/2 + 0.15);
    }
}

hex_head_screw();