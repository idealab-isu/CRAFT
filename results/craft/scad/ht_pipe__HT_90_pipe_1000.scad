// HT 90 pipe (DN90) - 1000 mm length
// One connected solid, oriented along X so front/back/left/right show length.

$fn = 128;

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 90; //[50:180:1]
length_mm = 1000; //[500:2000:10]
include_end_fitting = 1; //[0:1:1]

// Typical HT DN90 approximations (editable)
pipe_od = 90; //[50:180:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]

// Socket (muffe) at one end
fitting_length = 60; //[30:120:1]
fitting_wall = 4; //[2:8:0.1]
fitting_od_extra = 10; //[5:20:1]
socket_clearance = 0.6; //[0.2:1.5:0.1]

// Overlap to guarantee manifold union
overlap = 1; //[0.5:2:0.1]

// Derived
pipe_or = pipe_od/2;
pipe_ir = pipe_or - pipe_wall;

socket_or = pipe_or + fitting_od_extra/2;
socket_ir = pipe_or + socket_clearance;

// Safety clamps
pipe_ir_safe = max(0.01, pipe_ir);
socket_ir_safe = max(0.01, min(socket_or - 0.01, socket_ir));

module tube_x(len, ro, ri) {
    // Hollow tube along X axis, starting at x=0
    rotate([0, 90, 0])
        difference() {
            cylinder(h=len, r=ro, center=false);
            translate([0, 0, -0.01])
                cylinder(h=len + 0.02, r=ri, center=false);
        }
}

module ht_pipe() {
    color([0.85, 0.85, 0.8])
    union() {
        // Main pipe body
        tube_x(length_mm, pipe_or, pipe_ir_safe);

        // End socket (connected with calculated overlap)
        if (include_end_fitting) {
            translate([length_mm - overlap, 0, 0])
                tube_x(fitting_length, socket_or, socket_ir_safe);
        }
    }
}

ht_pipe();