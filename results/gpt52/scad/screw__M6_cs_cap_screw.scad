$fn=96;

module socket_head_cap_screw(d=6, head_d=12, length=10, head_h=6, socket_d=6, socket_depth=4, chamfer=0.6) {
    union() {
        // Shank
        translate([0,0,-length/2])
            cylinder(h=length, d=d);

        // Head
        translate([0,0,length/2])
            difference() {
                cylinder(h=head_h, d=head_d);
                // Hex socket
                translate([0,0,head_h - socket_depth])
                    cylinder(h=socket_depth + 0.2, d=socket_d, $fn=6);
                // Top chamfer
                translate([0,0,head_h - chamfer])
                    cylinder(h=chamfer + 0.01, d1=head_d, d2=head_d - 2*chamfer);
            }
    }
}

socket_head_cap_screw(d=6, head_d=12, length=10, head_h=6, socket_d=6, socket_depth=4, chamfer=0.6);