$fn=96;

module socket_head_cap_screw(d=8.0, head_d=16.0, length=10.0, head_h=8.0, socket_d=8.0, socket_depth=5.0, chamfer=0.6) {
    union() {
        // Shank
        translate([0,0,-length/2])
            cylinder(d=d, h=length, center=true);

        // Head
        translate([0,0,length/2 + head_h/2])
        difference() {
            union() {
                cylinder(d=head_d, h=head_h, center=true);
                // Top chamfer
                translate([0,0,head_h/2 - chamfer/2])
                    cylinder(d1=head_d, d2=head_d - 2*chamfer, h=chamfer, center=true);
                // Bottom chamfer
                translate([0,0,-head_h/2 + chamfer/2])
                    cylinder(d1=head_d - 2*chamfer, d2=head_d, h=chamfer, center=true);
            }
            // Hex socket (approximated by 6-sided prism)
            translate([0,0,head_h/2 - socket_depth/2])
                cylinder(d=socket_d, h=socket_depth, center=true, $fn=6);
        }
    }
}

socket_head_cap_screw(d=8.0, head_d=16.0, length=10.0, head_h=8.0, socket_d=8.0, socket_depth=5.0, chamfer=0.6);