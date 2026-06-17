// Parameters
pipe_standard = 0; //[0:0:1]
nominal_diameter_mm = 50; //[25:100:1]
length_mm = 2000; //[1000:4000:10]
pipe_od_mm = 50; //[25:100:1]
wall_thickness_mm = 2.4; //[1.2:4.8:0.1]
fitting_length_mm = 35; //[20:70:1]
fitting_od_factor = 1.25; //[1.1:1.6:0.01]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

// HT Pipe - one connected solid (hollow tube + integrated socket)
module ht_pipe() {
    eps = 0.02;

    od_r = pipe_od_mm/2;
    id_r = max(0.01, od_r - wall_thickness_mm);

    socket_od_r = (pipe_od_mm * fitting_od_factor)/2;
    socket_len  = fitting_length_mm;

    // Overlap must be positive and less than socket length
    ov = max(eps, min(overlap_mm, socket_len - eps));

    // Place socket so it overlaps the pipe by ov (guaranteed connection)
    socket_z0 = length_mm - socket_len - ov;

    color([0.85, 0.85, 0.8])
    union() {
        // Main pipe (hollow)
        difference() {
            cylinder(h=length_mm, r=od_r, center=false);
            translate([0, 0, -eps])
                cylinder(h=length_mm + 2*eps, r=id_r, center=false);
        }

        // Integrated end fitting (socket) - hollow ring overlapping the pipe
        translate([0, 0, socket_z0])
        difference() {
            cylinder(h=socket_len, r=socket_od_r, center=false);
            // Inner bore matches pipe OD
            translate([0, 0, -eps])
                cylinder(h=socket_len + 2*eps, r=od_r, center=false);
        }
    }
}

// Assembly
ht_pipe();