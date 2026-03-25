// M4x10 Hex Head Screw (single connected solid)
// Requested: 4.0mm shank diameter, 8.1mm head diameter (across flats), head height 2.925mm, length 10mm

shaft_diameter_mm   = 4.0;
overall_length_mm   = 10.0;     // length under head
head_across_flats_mm= 8.1;      // hex across flats
head_height_mm      = 2.925;

under_head_transition_height_mm = 0.8;  // small fillet-like taper (kept modest)
tip_chamfer_height_mm           = 0.6;  // small lead-in at tip
overlap_mm                      = 0.05; // tiny overlap to guarantee manifold union

$fn = 96;

module hex_head_screw() {
    head_r_circ = (head_across_flats_mm/2) / cos(30); // circumscribed radius for hex
    shank_r     = shaft_diameter_mm/2;

    union() {
        // Shank (under-head length)
        translate([0,0, -overall_length_mm])
            cylinder(h=overall_length_mm + overlap_mm, r=shank_r, $fn=64);

        // Tip chamfer (keeps overall under-head length at 10mm; chamfer is within that length)
        translate([0,0, -overall_length_mm])
            cylinder(h=tip_chamfer_height_mm, r1=0.01, r2=shank_r, $fn=64);

        // Under-head transition (taper from shank to head)
        translate([0,0, -under_head_transition_height_mm])
            cylinder(h=under_head_transition_height_mm + overlap_mm,
                     r1=shank_r, r2=head_r_circ, $fn=64);

        // Hex head (sits on z=0 plane, extends upward)
        translate([0,0, 0])
            cylinder(h=head_height_mm, r=head_r_circ, $fn=6);
    }
}

hex_head_screw();