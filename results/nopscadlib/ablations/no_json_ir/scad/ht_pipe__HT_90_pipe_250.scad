$fn = 120;

// HT 90 pipe 250 mm (simple exterior with one socket end)
pipe_len   = 250;
pipe_od    = 110;   // assumed outer diameter
socket_od  = 120;   // socket outer diameter
socket_h   = 30;

overlap = 1;        // small overlap to guarantee manifold union

module ht_pipe_body(h) {
    cylinder(h=h, d=pipe_od, center=false);
}

module end_fitting_socket() {
    // Solid socket ring (outer sleeve)
    difference() {
        cylinder(h=socket_h, d=socket_od, center=false);
        translate([0, 0, -overlap])
            cylinder(h=socket_h + 2*overlap, d=pipe_od, center=false);
    }
}

module ht_pipe() {
    body_h = pipe_len - socket_h;

    // Ensure ONE connected solid by overlapping the socket with the body
    union() {
        ht_pipe_body(pipe_len);
        translate([0, 0, pipe_len - socket_h - overlap])
            end_fitting_socket();
    }
}

ht_pipe();