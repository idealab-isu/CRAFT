// HT 40 pipe segment, length 150 mm (ONE connected solid)

$fn = 160;

// Dimensions (mm)
outer_diameter   = 50;
wall_thickness   = 3;
length           = 150;

// End collar (ring)
collar_extra_d   = 5;    // added to OD
collar_h         = 10;

// Robust boolean/connection helpers
eps = 0.02;              // tiny epsilon to avoid coplanar faces
overlap = 1.0;           // guaranteed overlap into pipe for connectivity

inner_diameter = outer_diameter - 2*wall_thickness;

module pipe_shell(h, d_out, d_in) {
    difference() {
        cylinder(h=h, d=d_out, center=false);
        translate([0, 0, -eps])
            cylinder(h=h + 2*eps, d=d_in, center=false);
    }
}

module collar_at(z0) {
    // Collar overlaps the pipe by 'overlap' so union is a single connected solid
    difference() {
        translate([0, 0, z0 - overlap])
            cylinder(h=collar_h + overlap, d=outer_diameter + collar_extra_d, center=false);
        translate([0, 0, z0 - overlap - eps])
            cylinder(h=collar_h + overlap + 2*eps, d=inner_diameter, center=false);
    }
}

module ht_pipe() {
    union() {
        pipe_shell(length, outer_diameter, inner_diameter);

        // Bottom collar starts at z=0 and overlaps into pipe
        collar_at(0);

        // Top collar starts at z=length-collar_h and overlaps into pipe
        collar_at(length - collar_h);
    }
}

ht_pipe();