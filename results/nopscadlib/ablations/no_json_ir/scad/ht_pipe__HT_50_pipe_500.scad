// HT 50 pipe 500 mm (one connected solid)

$fn = 160;

// Parameters
pipe_diameter   = 50;    // outer diameter (mm)
pipe_thickness  = 1.8;   // wall thickness (mm)
pipe_length     = 500;   // length (mm)

// Integrated end fitting (simple socket flare)
socket_len      = 10;    // axial length (mm)
socket_extra_d  = 10;    // added diameter at end (mm)

// Small overlap to guarantee watertight union/difference
eps = 0.2;

module ht_pipe() {
    od = pipe_diameter;
    id = od - 2*pipe_thickness;

    // Place the whole pipe centered on Z so it is visible in all standard views
    // (prevents "blank" orthographic views due to extreme extents/near clipping)
    translate([0, 0, -(pipe_length + socket_len)/2])
    union() {

        // Main hollow pipe body (from z=0 to z=pipe_length)
        difference() {
            cylinder(h = pipe_length, d = od, center = false);
            translate([0, 0, -eps])
                cylinder(h = pipe_length + 2*eps, d = id, center = false);
        }

        // Integrated end fitting (hollow flare), connected with overlap
        translate([0, 0, pipe_length - eps])
        difference() {
            cylinder(h = socket_len + eps, d1 = od, d2 = od + socket_extra_d, center = false);
            translate([0, 0, -eps])
                cylinder(h = socket_len + 3*eps, d1 = id, d2 = id + socket_extra_d, center = false);
        }
    }
}

ht_pipe();