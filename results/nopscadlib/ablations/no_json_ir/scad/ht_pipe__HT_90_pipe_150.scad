$fn = 128;

module ht_pipe(d_outer=150, length=150, wall=5, socket_len=20, socket_wall_extra=3, overlap=0.5) {
    d_inner = d_outer - 2*wall;
    d_socket_outer = d_outer + 2*socket_wall_extra;

    // Robustness epsilons to avoid coincident faces (blank/empty renders)
    eps = 0.01;
    bore_extra = 2; // ensures full cut-through

    difference() {
        union() {
            // Main outer body (not centered to keep end math simple)
            cylinder(d=d_outer, h=length, center=false);

            // Integrated sockets on both ends (overlap into body for connectivity)
            translate([0, 0, length - overlap])
                cylinder(d=d_socket_outer, h=socket_len, center=false);

            translate([0, 0, -socket_len + overlap])
                cylinder(d=d_socket_outer, h=socket_len, center=false);
        }

        // Continuous through-bore (slightly extended and slightly larger to avoid z-fighting)
        translate([0, 0, -bore_extra/2])
            cylinder(d=d_inner + eps, h=length + 2*socket_len + bore_extra, center=false);
    }
}

ht_pipe(d_outer=150, length=150, wall=5, socket_len=20, socket_wall_extra=3, overlap=0.5);