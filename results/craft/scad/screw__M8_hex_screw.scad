// Hex head screw (single connected solid)
// Specs: 8.0mm shank diameter, 15.0mm head diameter (across flats), head height 5.65mm, 10.0mm length under head

shaft_diameter_mm      = 8.0;
head_across_flats_mm   = 15.0;
head_height_mm         = 5.65;
length_under_head_mm   = 10.0;

// Small overlap to guarantee watertight union
overlap_mm = 0.2;

// Derived: hex circumradius from across-flats (AF = 2*R*cos(30) => R = AF / sqrt(3))
hex_circumradius_mm = head_across_flats_mm / sqrt(3);

module hex_head_screw() {
    union() {
        // Head: sits on top of the under-head plane at z=0
        translate([0, 0, head_height_mm/2])
            cylinder(r=hex_circumradius_mm, h=head_height_mm, $fn=6, center=true);

        // Shank: starts at z=0 and extends downward length_under_head_mm
        translate([0, 0, -length_under_head_mm/2 - overlap_mm/2])
            cylinder(r=shaft_diameter_mm/2, h=length_under_head_mm + overlap_mm, $fn=96, center=true);
    }
}

hex_head_screw();