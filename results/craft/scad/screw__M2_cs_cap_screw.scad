$fn = 96;

// Target dimensions (mm)
shank_diameter_mm = 2.0;
head_diameter_mm  = 3.8;
length_mm         = 10.0;   // under-head length
head_height_mm    = 2.0;

// Socket (approx for M2)
hex_socket_af_mm      = 1.5;  // across flats
hex_socket_depth_mm   = 1.0;

// Small overlaps to ensure watertight unions/differences
overlap_mm = 0.05;

// Hex prism sized by across-flats (AF)
module hex_prism_af(af, h, center=false) {
    // For a regular hexagon: AF = 2 * apothem, and apothem = R*cos(30)
    // => R (circumradius) = AF / (2*cos(30))
    R = af / (2*cos(30));
    cylinder(h=h, r=R, $fn=6, center=center);
}

module socket_head_cap_screw() {
    // Place head on top of shank: shank spans z=[0, length], head spans z=[length, length+head_height]
    difference() {
        union() {
            // Shank (cylindrical)
            translate([0, 0, length_mm/2])
                cylinder(h=length_mm, r=shank_diameter_mm/2, center=true);

            // Head (cylindrical)
            translate([0, 0, length_mm + head_height_mm/2 - overlap_mm])
                cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);
        }

        // Hex socket recess cut into head from the top
        // Top of head is at z = length + head_height
        translate([0, 0, length_mm + head_height_mm - hex_socket_depth_mm/2 + overlap_mm])
            hex_prism_af(hex_socket_af_mm, hex_socket_depth_mm + 2*overlap_mm, center=true);
    }
}

socket_head_cap_screw();