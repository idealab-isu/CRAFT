$fn=96;

module socket_head_cap_screw(d=2.5, L=10, head_d=4.5, head_h=2.5) {
    socket_af = head_d * 0.45;
    socket_depth = head_h * 0.65;
    socket_r = socket_af / sqrt(3);
    union() {
        translate([0,0,-L/2]) cylinder(d=d, h=L, $fn=96);
        translate([0,0,L/2]) difference() {
            cylinder(d=head_d, h=head_h, $fn=96);
            translate([0,0,head_h - socket_depth])
                cylinder(r=socket_r, h=socket_depth + 0.2, $fn=6);
        }
    }
}

socket_head_cap_screw();