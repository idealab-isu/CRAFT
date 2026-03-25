$fn=96;

module socket_head_cap_screw(d=4.0, head_d=8.0, length=10.0, head_h=4.0, socket_d=4.0, socket_depth=2.5) {
    union() {
        translate([0,0,-length/2])
            cylinder(d=d, h=length, $fn=96);

        translate([0,0,length/2])
            difference() {
                cylinder(d=head_d, h=head_h, $fn=96);
                translate([0,0,head_h - socket_depth])
                    cylinder(d=socket_d, h=socket_depth + 0.2, $fn=6);
            }
    }
}

socket_head_cap_screw(d=4.0, head_d=8.0, length=10.0, head_h=4.0, socket_d=4.0, socket_depth=2.5);