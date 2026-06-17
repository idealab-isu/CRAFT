$fn = 128;

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 50; //[25:100:1]
length_mm = 150; //[75:300:1]
type_descriptor = 1; //[1:1:1]
pipe_od = 50; //[25:100:1]
pipe_wall = 1.8; //[0.9:3.6:0.1]
fitting_length = 18; //[9:36:1]
fitting_od_scale = 1.12; //[1.05:1.3:0.01]
fitting_wall_extra = 1.2; //[0.6:2.4:0.1]
connection_overlap = 1; //[0.5:2:0.1]

eps = 0.05;

module ht_pipe_150_with_socket() {
    // Derived dimensions
    pipe_r_out = pipe_od/2;
    pipe_r_in  = max(0.01, pipe_r_out - pipe_wall);

    fit_od    = pipe_od * fitting_od_scale;
    fit_r_out = fit_od/2;
    fit_wall  = pipe_wall + fitting_wall_extra;
    fit_r_in  = max(0.01, fit_r_out - fit_wall);

    // Socket at bottom end (z=0), overlapping into pipe by connection_overlap
    overlap = min(connection_overlap, fitting_length - eps);
    pipe_z0 = fitting_length - overlap;          // pipe starts inside socket to ensure connectivity
    pipe_h  = max(eps, length_mm - pipe_z0);     // total length from z=0 to z=length_mm

    color([0.85, 0.85, 0.8])
    difference() {
        // Outer solid (connected)
        union() {
            // Socket outer
            cylinder(h=fitting_length, r=fit_r_out, center=false);

            // Main pipe outer (starts inside socket by overlap)
            translate([0, 0, pipe_z0])
                cylinder(h=pipe_h, r=pipe_r_out, center=false);
        }

        // Inner voids (connected cavity)
        union() {
            // Socket inner (open mouth at z=0)
            cylinder(h=fitting_length + eps, r=fit_r_in, center=false);

            // Main pipe inner (starts at pipe start; open at top)
            translate([0, 0, pipe_z0])
                cylinder(h=pipe_h + eps, r=pipe_r_in, center=false);
        }
    }
}

ht_pipe_150_with_socket();