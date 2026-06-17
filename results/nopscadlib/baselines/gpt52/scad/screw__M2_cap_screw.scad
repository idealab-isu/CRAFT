$fn=96;

module socket_head_cap_screw(d=2.0, L=10.0, head_d=3.8, head_h=2.0) {
    socket_af = 1.5;
    socket_depth = 1.2;
    socket_corner_r = 0.15;
    head_top_chamfer = 0.2;

    module hex_prism(af, h) {
        r = af / sqrt(3);
        cylinder(h=h, r=r, center=false, $fn=6);
    }

    module rounded_hex_socket(af, depth, corner_r) {
        union() {
            hex_prism(af, depth);
            for (a = [0:60:300]) {
                rotate([0,0,a]) translate([af/2,0,0]) cylinder(h=depth, r=corner_r, center=false, $fn=48);
            }
        }
    }

    difference() {
        union() {
            translate([0,0,-L/2]) cylinder(h=L, d=d, center=false, $fn=96);

            translate([0,0,L/2]) cylinder(h=head_h, d=head_d, center=false, $fn=96);

            translate([0,0,L/2 + head_h - head_top_chamfer])
                cylinder(h=head_top_chamfer, d1=head_d, d2=head_d - 2*head_top_chamfer, center=false, $fn=96);
        }

        translate([0,0,L/2 + head_h - socket_depth])
            rounded_hex_socket(socket_af, socket_depth, socket_corner_r);
    }
}

socket_head_cap_screw();