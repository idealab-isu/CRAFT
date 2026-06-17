$fn = 96;

// Target dimensions (mm)
shaft_diameter_mm = 4.0;
length_mm         = 10.0;   // under-head length
head_diameter_mm  = 7.0;
head_height_mm    = 4.0;

// Socket (approx for M4 SHCS)
socket_across_flats_mm = 3.0;
socket_depth_mm        = 2.5;

// Small overlaps / clearances
overlap_mm   = 0.2;   // ensures watertight unions
socket_clear = 0.15;  // makes socket visible/printable

module socket_head_cap_screw(
    d=shaft_diameter_mm,
    L=length_mm,
    head_d=head_diameter_mm,
    head_h=head_height_mm,
    sock_af=socket_across_flats_mm,
    sock_depth=socket_depth_mm
){
    r_shank = d/2;
    r_head  = head_d/2;

    // Hex socket circumscribed radius from across-flats
    r_hex = (sock_af/2) / cos(30);

    // Place underside of head at z=0, head up (+z), shank down (-z)
    difference() {
        union() {
            // Shank
            translate([0,0,-L/2])
                cylinder(h=L, r=r_shank, center=true);

            // Head (clean cylinder)
            translate([0,0, head_h/2 - overlap_mm/2])
                cylinder(h=head_h + overlap_mm, r=r_head, center=true);
        }

        // Internal hex socket cut from top face
        translate([0,0, head_h - sock_depth/2])
            cylinder(h=sock_depth + overlap_mm,
                     r=r_hex + socket_clear,
                     center=true,
                     $fn=6);
    }
}

socket_head_cap_screw();