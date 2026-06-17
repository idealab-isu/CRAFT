// HT 50 pipe 500 mm (single connected solid)

// Parameters
nominal_size    = 50;   //[25:110:1]
length_mm       = 500;  //[250:1000:1]
pipe_od         = 50;   //[25:100:0.5]
wall_thickness  = 1.8;  //[0.9:3.6:0.1]
fitting_length  = 45;   //[20:90:1]
fitting_od      = 58;   //[45:90:0.5]
fitting_wall    = 2.5;  //[1.2:5:0.1]
overlap         = 1;    //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
    // Safety clamps to avoid invalid geometry
    pipe_r      = pipe_od/2;
    pipe_ir     = max(0.01, pipe_r - wall_thickness);

    fit_r       = fitting_od/2;
    fit_ir      = max(0.01, fit_r - fitting_wall);

    // Place socket at the end, overlapping into the pipe by "overlap"
    socket_z0   = length_mm - overlap;

    // Ensure inner voids fully cut through (avoid coplanar faces)
    eps = 0.05;

    color([0.85, 0.85, 0.8])
    union() {
        // Main pipe (hollow)
        difference() {
            cylinder(h=length_mm, r=pipe_r, center=false);
            translate([0, 0, -eps])
                cylinder(h=length_mm + 2*eps, r=pipe_ir, center=false);
        }

        // End socket (hollow), connected by overlap
        translate([0, 0, socket_z0])
        difference() {
            cylinder(h=fitting_length, r=fit_r, center=false);
            translate([0, 0, -eps])
                cylinder(h=fitting_length + 2*eps, r=fit_ir, center=false);
        }
    }
}

ht_pipe();