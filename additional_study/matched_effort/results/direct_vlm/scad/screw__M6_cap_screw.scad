$fn = 96;

module socket_head_cap_screw(d=6.0, head_d=10.0, head_h=6.0, L=10.0) {
    // Approximate ISO 4762 proportions for M6:
    // Hex socket across flats ~ 5mm, depth ~ 3mm
    socket_af = 5.0;
    socket_depth = 3.0;
    socket_corner_r = 0.2;

    // Small under-head fillet approximation
    underhead_r = 0.4;

    // Helper: hex prism sized by across-flats
    module hex_prism(af, h) {
        // For a regular hexagon, across-flats = 2 * apothem = sqrt(3) * R
        // where R is circumradius (center to vertex)
        R = af / sqrt(3);
        cylinder(h=h, r=R, $fn=6);
    }

    difference() {
        union() {
            // Shank
            cylinder(h=L, d=d);

            // Head (with slight under-head fillet via hull)
            translate([0,0,L])
            hull() {
                cylinder(h=0.01, d=head_d);
                translate([0,0,-underhead_r])
                    cylinder(h=0.01, d=head_d - 2*underhead_r);
            }
            translate([0,0,L])
                cylinder(h=head_h, d=head_d);
        }

        // Socket recess
        translate([0,0,L + head_h - socket_depth])
            hex_prism(socket_af, socket_depth + 0.2);

        // Slight chamfer at socket opening (approx)
        translate([0,0,L + head_h - 0.6])
            cylinder(h=0.6 + 0.2, d1=socket_af*1.25, d2=socket_af*1.05, $fn=48);
    }
}

socket_head_cap_screw(d=6.0, head_d=10.0, head_h=6.0, L=10.0);