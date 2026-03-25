$fn=96;

module socket_head_cap_screw(d=3.0, L=10.0, head_d=5.5, head_h=3.0, socket_d=2.5, socket_depth=2.0) {
    union() {
        translate([0,0,-L/2])
            cylinder(d=d, h=L, $fn=96);

        translate([0,0,L/2])
            difference() {
                cylinder(d=head_d, h=head_h, $fn=96);
                translate([0,0,head_h - socket_depth])
                    cylinder(d=socket_d, h=socket_depth + 0.2, $fn=96);
            }
    }
}

socket_head_cap_screw(d=3.0, L=10.0, head_d=5.5, head_h=3.0, socket_d=2.5, socket_depth=2.0);