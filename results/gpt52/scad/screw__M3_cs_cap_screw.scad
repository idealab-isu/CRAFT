$fn=96;

module socket_head_cap_screw(d=3.0, L=10.0, head_d=6.0, head_h=3.0, hex_flat=2.5, hex_depth=1.8, chamfer=0.35) {
    union() {
        translate([0,0,-L/2])
            cylinder(h=L, d=d);

        translate([0,0,L/2])
        difference() {
            cylinder(h=head_h, d=head_d);

            translate([0,0,head_h-hex_depth])
                cylinder(h=hex_depth+0.02, d=hex_flat / cos(30), $fn=6);

            translate([0,0,head_h-chamfer])
                cylinder(h=chamfer+0.02, d1=head_d, d2=head_d-2*chamfer);
        }
    }
}

socket_head_cap_screw(d=3.0, L=10.0, head_d=6.0, head_h=3.0, hex_flat=2.5, hex_depth=1.8, chamfer=0.35);