$fn=96;

module hex_socket(h=1.6, af=1.5) {
    // across flats af; hex radius to vertices:
    r = af / (2*cos(30));
    cylinder(h=h, r=r, $fn=6);
}

module m3_grub_screw(L=6, d=3, pitch=0.5, thread_depth=0.18, socket_depth=1.6, socket_af=1.5, chamfer=0.35) {
    difference() {
        union() {
            // main body
            cylinder(h=L, d=d);

            // slight top chamfer
            translate([0,0,L-chamfer])
                cylinder(h=chamfer, d1=d, d2=d-2*chamfer);

            // slight bottom chamfer
            cylinder(h=chamfer, d1=d-2*chamfer, d2=d);
        }

        // hex socket
        translate([0,0,L-socket_depth])
            hex_socket(h=socket_depth+0.2, af=socket_af);

        // thread approximation: helical triangular groove
        turns = L / pitch;
        linear_extrude(height=L+0.4, twist=-360*turns, slices=ceil(turns*40), convexity=10)
            translate([d/2 - thread_depth, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [thread_depth, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

m3_grub_screw(L=6);