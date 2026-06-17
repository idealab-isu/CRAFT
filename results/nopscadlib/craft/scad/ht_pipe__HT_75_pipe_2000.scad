// Parameters
pipe_standard = 0; //[0:1:1]
nominal_diameter_mm = 75; //[40:150:1]
length_mm = 2000; //[1000:4000:10]
pipe_od_mm = 75; //[40:150:1]
pipe_wall_mm = 2.7; //[1.5:6:0.1]
fitting_length_mm = 55; //[30:120:1]
fitting_od_extra_mm = 6; //[2:20:0.5]
fitting_wall_extra_mm = 1.3; //[0.5:4:0.1]
socket_depth_mm = 40; //[20:90:1]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

// HT Pipe - one connected solid
module ht_pipe() {
    // Derived radii
    pipe_ro = pipe_od_mm/2;
    pipe_ri = max(0.01, pipe_ro - pipe_wall_mm);

    fit_ro  = pipe_ro + fitting_od_extra_mm/2;
    fit_wall = pipe_wall_mm + fitting_wall_extra_mm;
    fit_ri  = max(0.01, fit_ro - fit_wall);

    // Ensure socket depth doesn't exceed fitting length
    sock_d = min(socket_depth_mm, fitting_length_mm);

    // Place fitting so it overlaps the pipe by overlap_mm (guaranteed connection)
    fit_z0 = length_mm - fitting_length_mm - overlap_mm;

    color([0.85, 0.85, 0.8])
    union() {
        // Main pipe (hollow)
        difference() {
            cylinder(h=length_mm, r=pipe_ro, center=false);
            translate([0, 0, -0.01])
                cylinder(h=length_mm + 0.02, r=pipe_ri, center=false);
        }

        // Integrated socket/fitting (hollow, open at end)
        translate([0, 0, fit_z0])
        difference() {
            cylinder(h=fitting_length_mm + overlap_mm, r=fit_ro, center=false);

            // Inner void: full length to keep it a socket (open end),
            // with slight extension for robust boolean
            translate([0, 0, -0.01])
                cylinder(h=fitting_length_mm + overlap_mm + 0.02, r=fit_ri, center=false);
        }
    }
}

ht_pipe();