$fn=96;

module socket_head_cap_screw(d=6.0, head_d=10.0, head_h=6.0, shank_l=10.0, socket_af=5.0, socket_depth=4.0, chamfer=0.6) {
    union() {
        // Shank (centered at origin along Z)
        translate([0,0,-shank_l/2])
            cylinder(h=shank_l, d=d);

        // Head on top of shank
        translate([0,0,shank_l/2])
        difference() {
            union() {
                cylinder(h=head_h, d=head_d);
                // Top chamfer
                translate([0,0,head_h-chamfer])
                    cylinder(h=chamfer, d1=head_d, d2=head_d-2*chamfer);
                // Bottom fillet-ish chamfer
                cylinder(h=chamfer, d1=head_d-2*chamfer, d2=head_d);
            }
            // Hex socket
            translate([0,0,head_h - socket_depth])
                cylinder(h=socket_depth + 0.02, d=socket_af / cos(30), $fn=6);
        }
    }
}

socket_head_cap_screw(d=6.0, head_d=10.0, head_h=6.0, shank_l=10.0, socket_af=5.0, socket_depth=4.0, chamfer=0.6);