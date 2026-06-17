// Hex head screw (simple solid, no washer/buzzer/spacer)
// Specs: 3.0mm shank diameter, 6.4mm head diameter (across flats), head height 2.125mm, 10mm long (under head)

$fn = 96;

// Parameters (mm)
shaft_diameter_mm   = 3.0;
shaft_radius_mm     = shaft_diameter_mm/2;

length_under_head_mm = 10.0;     // shank length (under head)
head_across_flats_mm = 6.4;      // hex across flats
head_height_mm       = 2.125;

overlap_mm = 0.05;               // small overlap to ensure one connected solid

module hex_head_screw() {
    // Place bottom of shank at z=0, top of head at z=length_under_head+head_height
    union() {
        // Shank
        translate([0, 0, length_under_head_mm/2])
            cylinder(r=shaft_radius_mm, h=length_under_head_mm, center=true);

        // Hex head (across flats = head_across_flats_mm)
        // For a hex made with cylinder($fn=6), the given r is circumradius.
        // Across flats = 2 * r * cos(30) => r = (across_flats/2)/cos(30)
        head_r = (head_across_flats_mm/2) / cos(30);

        translate([0, 0, length_under_head_mm + head_height_mm/2 - overlap_mm/2])
            cylinder(r=head_r, h=head_height_mm + overlap_mm, center=true, $fn=6);
    }
}

hex_head_screw();