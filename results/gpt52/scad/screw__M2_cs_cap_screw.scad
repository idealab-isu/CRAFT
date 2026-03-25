$fn=96;

module socket_head_cap_screw(d=2.0, L=10.0, head_d=3.8, head_h=2.0, socket_d=1.5, socket_depth=1.2) {
    union() {
        translate([0,0,-L/2])
            cylinder(h=L, d=d);

        translate([0,0,L/2 - head_h])
            difference() {
                cylinder(h=head_h, d=head_d);
                translate([0,0,head_h - socket_depth])
                    cylinder(h=socket_depth + 0.02, d=socket_d);
            }
    }
}

socket_head_cap_screw();