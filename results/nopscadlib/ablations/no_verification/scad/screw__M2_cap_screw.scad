// Socket Head Cap Screw (single connected solid)
// Requested: shank Ø2.0mm, head Ø3.8mm, head height 2.0mm, length 10mm

$fn = 96;

// Parameters (mm)
shank_diameter_mm   = 2.0;
head_diameter_mm    = 3.8;
head_height_mm      = 2.0;
overall_length_mm   = 10.0;

// Hex socket (approx for this size)
hex_socket_af_mm    = 1.5;   // across flats
hex_socket_depth_mm = 1.0;

// Small edge details
head_top_chamfer_mm = 0.2;
tip_chamfer_mm      = 0.3;

// Robust boolean overlap
eps = 0.02;

module hex_prism(af, h, center=false) {
    // Regular hex with across-flats = af
    // For a regular hex: af = 2 * R * cos(30)  => R = af / (2*cos(30))
    R = af / (2*cos(30));
    cylinder(h=h, r=R, $fn=6, center=center);
}

module socket_head_cap_screw() {
    r_shank = shank_diameter_mm/2;
    r_head  = head_diameter_mm/2;

    // Place screw along +Z, with tip at Z=0 and head top at Z=overall_length+head_height
    difference() {
        union() {
            // Shank
            translate([0,0, overall_length_mm/2])
                cylinder(h=overall_length_mm, r=r_shank, center=true);

            // Tip chamfer (conical)
            translate([0,0, tip_chamfer_mm/2])
                cylinder(h=tip_chamfer_mm, r1=0, r2=r_shank, center=true);

            // Head (cylindrical)
            translate([0,0, overall_length_mm + head_height_mm/2 - eps])
                cylinder(h=head_height_mm, r=r_head, center=true);

            // Small top chamfer on head (frustum)
            translate([0,0, overall_length_mm + head_height_mm - head_top_chamfer_mm/2 - eps])
                cylinder(h=head_top_chamfer_mm, r1=r_head, r2=max(r_head - head_top_chamfer_mm, 0.01), center=true);
        }

        // Hex socket recess (subtracted)
        translate([0,0, overall_length_mm + head_height_mm - hex_socket_depth_mm/2 - eps])
            hex_prism(hex_socket_af_mm, hex_socket_depth_mm + 2*eps, center=true);
    }
}

socket_head_cap_screw();