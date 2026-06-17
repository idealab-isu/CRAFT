// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 90; //[50:180:1]
length_mm = 150; //[75:300:1]
orientation_straight = 1; //[1:1:1]
pipe_od = 90; //[50:180:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
fitting_length = 25; //[12:50:1]
fitting_radial_extra = 4; //[2:10:0.5]
overlap = 1; //[0.5:2:0.1]

$fn = 128;

// Module for HT Pipe (one connected solid)
module ht_pipe() {
    od = pipe_od;
    id = max(0.01, od - 2*pipe_wall);

    // Keep overlap valid and ensure a tiny epsilon to avoid coplanar artifacts
    ov  = min(overlap, fitting_length/2);
    eps = 0.02;

    // Outer radii
    r_main   = od/2;
    r_socket = r_main + fitting_radial_extra;

    // Z extents (all derived)
    z0 = 0;
    z1 = length_mm;
    z2 = length_mm + fitting_length;

    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER: main pipe + socket, guaranteed connected by overlap
        union() {
            cylinder(r=r_main, h=(z1 - z0), center=false);

            translate([0, 0, z1 - ov])
                cylinder(r=r_socket, h=(z2 - (z1 - ov)), center=false);
        }

        // INNER VOID: continuous bore through entire part
        translate([0, 0, z0 - ov - eps])
            cylinder(r=id/2, h=(z2 - z0) + 2*ov + 2*eps, center=false);
    }
}

// Assembly
module assembly() {
    ht_pipe();
}

assembly();