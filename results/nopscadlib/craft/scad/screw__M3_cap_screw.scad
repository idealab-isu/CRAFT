// Socket head cap screw (single connected solid)
// Requested: 3.0mm diameter shank, 5.5mm head diameter, 3.0mm head height, 10mm long

$fn = 96;

// Parameters
shaft_diameter_mm = 3.0;
length_mm         = 10.0;   // under-head length
head_diameter_mm  = 5.5;
head_height_mm    = 3.0;

// Socket (hex recess) parameters (typical for M3 SHCS)
socket_af_mm      = 2.5;    // across flats
socket_depth_mm   = 1.6;

// Small overlap to ensure watertight unions/differences
overlap_mm = 0.05;

module socket_head_cap_screw(
    d_shaft=3.0,
    L=10.0,
    d_head=5.5,
    h_head=3.0,
    af=2.5,
    socket_depth=1.6
){
    r_shaft = d_shaft/2;
    r_head  = d_head/2;

    // Hex radius for cylinder($fn=6) such that across-flats = af
    // For a regular hex: across_flats = 2 * r * cos(30)
    r_hex = af / (2*cos(30));

    // Clamp socket depth so it doesn't exceed head height
    sd = min(socket_depth, h_head - 0.2);

    difference() {
        union() {
            // Shank: from z=0 (under head) down to z=-L
            translate([0,0,-L/2])
                cylinder(h=L, r=r_shaft, center=true);

            // Head: from z=0 up to z=+h_head
            translate([0,0,h_head/2 - overlap_mm])
                cylinder(h=h_head + 2*overlap_mm, r=r_head, center=true);
        }

        // Hex socket recess: cut from top face downward
        translate([0,0,h_head - sd/2])
            cylinder(h=sd + overlap_mm, r=r_hex, center=true, $fn=6);
    }
}

socket_head_cap_screw(
    d_shaft=shaft_diameter_mm,
    L=length_mm,
    d_head=head_diameter_mm,
    h_head=head_height_mm,
    af=socket_af_mm,
    socket_depth=socket_depth_mm
);