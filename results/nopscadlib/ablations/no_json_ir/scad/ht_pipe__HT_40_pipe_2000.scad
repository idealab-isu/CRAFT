// HT 40 pipe 2000 mm (single connected solid)

// Parameters
pipe_diameter  = 40;    // outer diameter (mm)
pipe_thickness = 3;     // wall thickness (mm)
pipe_length    = 2000;  // length (mm)

socket_length  = 10;    // end socket length (mm)
overlap        = 0.5;   // overlap to guarantee connectivity (mm)

$fn = 128;

module ht_pipe() {
    inner_d = pipe_diameter - 2*pipe_thickness;

    // Build as one connected solid: outer union minus inner void union
    difference() {
        union() {
            // Outer main pipe
            cylinder(h=pipe_length, d=pipe_diameter, center=true);

            // Outer socket (same OD), overlapped into main pipe
            translate([0, 0, pipe_length/2 + socket_length/2 - overlap])
                cylinder(h=socket_length, d=pipe_diameter, center=true);
        }

        union() {
            // Inner void for main pipe (slightly longer to ensure clean subtraction)
            cylinder(h=pipe_length + 2, d=inner_d, center=true);

            // Inner void for socket (also slightly longer), aligned with socket
            translate([0, 0, pipe_length/2 + socket_length/2 - overlap])
                cylinder(h=socket_length + 2, d=inner_d, center=true);
        }
    }
}

ht_pipe();