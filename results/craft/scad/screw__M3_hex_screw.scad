// Simple hex head screw (single connected solid)
// Requested: 3.0mm shank diameter, 6.4mm head diameter, head height 2.125mm, 10mm long (under-head length)

shaft_diameter_mm = 3.0;
overall_length_mm = 10.0;     // under-head length
head_diameter_mm  = 6.4;      // across corners for $fn=6 cylinder
head_height_mm    = 2.125;

connection_overlap_mm = 0.2;  // small overlap to guarantee manifold union

$fn = 64;

module hex_head_screw() {
    union() {
        // Shaft: from z=0 (under head) down to z=-overall_length_mm
        translate([0, 0, -overall_length_mm/2])
            cylinder(h = overall_length_mm + connection_overlap_mm,
                     r = shaft_diameter_mm/2,
                     center = true);

        // Hex head: sits on top of shaft, from z=0 up to z=head_height_mm
        translate([0, 0, head_height_mm/2 - connection_overlap_mm/2])
            cylinder(h = head_height_mm + connection_overlap_mm,
                     r = head_diameter_mm/2,
                     $fn = 6,
                     center = true);
    }
}

hex_head_screw();