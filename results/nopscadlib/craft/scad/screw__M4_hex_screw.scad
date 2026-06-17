// Hex head screw (single connected solid)
// Target: 4.0mm shaft diameter, 8.1mm hex head diameter (across flats),
//         head height 2.925mm, 10mm length under head.

shaft_diameter_mm      = 4.0;
length_under_head_mm   = 10.0;
head_diameter_mm       = 8.1;     // across flats
head_height_mm         = 2.925;

overlap_mm = 0.05;

$fn = 96;

module hex_head_screw() {
    r_shaft = shaft_diameter_mm/2;

    // For a hex made with cylinder($fn=6), the given radius is the circumradius.
    // Across flats (AF) = 2 * r * cos(30°)  =>  r = AF / (2*cos(30°))
    r_head = head_diameter_mm / (2 * cos(30));

    union() {
        // Hex head: underside at z=0, top at z=+head_height_mm
        translate([0, 0, head_height_mm/2])
            cylinder(h=head_height_mm, r=r_head, $fn=6, center=true);

        // Smooth shank: starts at underside of head (z=0) and extends to z=-length_under_head_mm
        translate([0, 0, -length_under_head_mm/2 - overlap_mm/2])
            cylinder(h=length_under_head_mm + overlap_mm, r=r_shaft, $fn=96, center=true);
    }
}

hex_head_screw();