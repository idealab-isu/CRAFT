$fn = 128;

module ht_pipe_segment(length=1000) {
    outer_diameter   = 160;   // mm
    wall_thickness   = 3.2;   // mm
    inner_diameter   = outer_diameter - 2*wall_thickness;

    socket_length    = 50;    // mm
    socket_diameter  = 170;   // mm

    ring_height      = 6;     // small outer ring at socket end (visual detail)
    ring_extra_d     = 4;     // ring OD = socket_diameter + ring_extra_d

    overlap          = 0.5;   // mm, ensures watertight unions/differences

    // Build as ONE connected solid: (outer union) - (inner void)
    difference() {
        union() {
            // Main outer pipe
            cylinder(h=length, d=outer_diameter, center=true);

            // Socket at +Z end (connected by formula, slight overlap into main)
            translate([0, 0, length/2 - overlap])
                cylinder(h=socket_length + overlap, d1=socket_diameter, d2=outer_diameter, center=false);

            // Small ring/lip at the very end of the socket
            translate([0, 0, length/2 + socket_length - ring_height])
                cylinder(h=ring_height, d=socket_diameter + ring_extra_d, center=false);
        }

        // Inner void through entire part (extends beyond to fully cut)
        cylinder(h=length + socket_length + ring_height + 4*overlap,
                 d=inner_diameter, center=true);
    }
}

ht_pipe_segment(1000);