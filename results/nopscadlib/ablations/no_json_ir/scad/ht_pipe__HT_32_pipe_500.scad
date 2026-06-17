$fn = 180;

// HT 32 pipe 500 mm (approx.): OD ~ 36 mm, wall ~ 2 mm, length 500 mm
module ht_pipe_32_500() {
    outer_d = 36;
    wall_t  = 2;
    length  = 500;

    // Simple socket/bell end
    socket_h  = 15;
    socket_od = 40;

    // Small overlaps to guarantee a single connected manifold solid
    z_overlap = 0.8;
    bore_eps  = 0.2;

    union() {
        // Main hollow pipe
        hollow_tube(outer_d=outer_d, wall_t=wall_t, h=length);

        // Socket at the top end, overlapping into the pipe
        translate([0, 0, length - z_overlap])
            socket_end(pipe_od=outer_d, pipe_wall=wall_t,
                       socket_od=socket_od, socket_h=socket_h,
                       bore_eps=bore_eps);
    }
}

module hollow_tube(outer_d, wall_t, h) {
    inner_d = outer_d - 2*wall_t;
    difference() {
        cylinder(d=outer_d, h=h, center=false);
        // Extend the cut slightly beyond both ends to avoid coplanar faces
        translate([0, 0, -1])
            cylinder(d=inner_d, h=h + 2, center=false);
    }
}

module socket_end(pipe_od, pipe_wall, socket_od, socket_h, bore_eps=0.2) {
    // Keep socket hollow and continuous with pipe bore
    inner_d = pipe_od - 2*pipe_wall;

    difference() {
        cylinder(d=socket_od, h=socket_h, center=false);
        // Slightly enlarge bore cut to ensure clean boolean and visible hollow
        translate([0, 0, -1])
            cylinder(d=inner_d + bore_eps, h=socket_h + 2, center=false);
    }
}

ht_pipe_32_500();