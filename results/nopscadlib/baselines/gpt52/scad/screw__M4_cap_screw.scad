$fn=96;

module socket_head_cap_screw(d=4.0, head_d=7.0, head_h=4.0, L=10.0, socket_d=3.0, socket_depth=2.5) {
    union() {
        translate([0,0,-L/2])
            cylinder(d=d, h=L, center=false);

        translate([0,0,L/2 - head_h])
            difference() {
                cylinder(d=head_d, h=head_h, center=false);
                translate([0,0,head_h - socket_depth])
                    cylinder(d=socket_d, h=socket_depth + 0.2, center=false);
            }
    }
}

socket_head_cap_screw(d=4.0, head_d=7.0, head_h=4.0, L=10.0, socket_d=3.0, socket_depth=2.5);