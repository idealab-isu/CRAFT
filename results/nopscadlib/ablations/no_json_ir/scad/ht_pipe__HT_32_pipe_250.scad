// HT 32 pipe 250 mm (single connected solid)

$fn = 120;

// Dimensions (mm)
outer_diameter   = 36.0;  // pipe OD
wall_thickness   = 1.8;   // pipe wall
length           = 250.0; // overall length
socket_length    = 20.0;  // socket axial length
socket_diameter  = 38.0;  // socket OD

// Robustness / connectivity
eps = 0.2; // small overlap to guarantee union connectivity and clean booleans

inner_diameter = outer_diameter - 2*wall_thickness;

module tube(h, od, id) {
    difference() {
        cylinder(h=h, d=od, center=false);
        translate([0, 0, -eps])
            cylinder(h=h + 2*eps, d=id, center=false);
    }
}

module ht_pipe() {
    union() {
        // Main pipe body (hollow)
        tube(length, outer_diameter, inner_diameter);

        // Socket at one end (hollow), overlapped into body for a single connected solid
        // Place socket so it extends beyond the end while overlapping by eps
        translate([0, 0, length - eps])
            tube(socket_length + eps, socket_diameter, outer_diameter);
    }
}

ht_pipe();