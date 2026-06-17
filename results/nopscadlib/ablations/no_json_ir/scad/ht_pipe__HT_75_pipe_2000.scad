// HT 75 pipe 2000 mm (single connected solid)

// Parameters
pipe_diameter  = 75;    // outer diameter (mm)
pipe_thickness = 3;     // wall thickness (mm)
pipe_length    = 2000;  // overall length (mm)

// Simple socket at one end (typical HT pipe)
socket_len     = 60;    // socket length (mm)
socket_extra_d = 10;    // socket OD increase (mm)

$fn = 128;

module ht_pipe() {
    od = pipe_diameter;
    id = od - 2*pipe_thickness;

    socket_od = od + socket_extra_d;
    socket_id = socket_od - 2*pipe_thickness;

    overlap = 0.5; // ensures union connectivity (no coincident faces)

    union() {
        // Main pipe body (hollow)
        difference() {
            cylinder(h=pipe_length, d=od);
            translate([0,0,-1])
                cylinder(h=pipe_length+2, d=id);
        }

        // Socket at one end (hollow), overlapping into main body
        translate([0,0,pipe_length - socket_len + overlap])
        difference() {
            cylinder(h=socket_len, d=socket_od);
            translate([0,0,-1])
                cylinder(h=socket_len+2, d=socket_id);
        }
    }
}

ht_pipe();