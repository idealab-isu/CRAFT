// HT 50 pipe 1000 mm (single connected solid)
// Units: mm

$fn = 128;

outer_diameter = 50;
wall_thickness = 1.8;
length = 1000;

// Simple socket/bell ends (kept connected and non-floating)
socket_len = 25;
socket_extra_d = 5;     // socket OD increase over pipe OD
taper_len = 10;         // tapered transition length
overlap = 0.5;          // small overlap to guarantee manifold union

inner_diameter = outer_diameter - 2 * wall_thickness;

module pipe_shell(h, od, id) {
    difference() {
        cylinder(h=h, d=od);
        translate([0,0,-0.1]) cylinder(h=h+0.2, d=id);
    }
}

module socket_end() {
    // Outer: taper + straight socket
    // Inner: keep same ID as pipe (simple representation)
    difference() {
        union() {
            cylinder(h=taper_len, d1=outer_diameter, d2=outer_diameter + socket_extra_d);
            translate([0,0,taper_len - overlap])
                cylinder(h=socket_len - taper_len + overlap, d=outer_diameter + socket_extra_d);
        }
        translate([0,0,-0.1]) cylinder(h=socket_len+0.2, d=inner_diameter);
    }
}

module ht_pipe() {
    union() {
        // Main pipe body
        pipe_shell(length, outer_diameter, inner_diameter);

        // Bottom socket (connected at z=0 with overlap)
        translate([0,0,-socket_len + overlap])
            socket_end();

        // Top socket (connected at z=length with overlap)
        translate([0,0,length - overlap])
            socket_end();
    }
}

ht_pipe();