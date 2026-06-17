$fn = 128;

// HT 50 pipe (nominal) - 1500 mm length
pipe_length     = 1500;   // mm
outer_diameter  = 50;     // mm
wall_thickness  = 1.8;    // mm
inner_diameter  = outer_diameter - 2*wall_thickness;

// Orient along X so FRONT/BACK/LEFT/RIGHT orthographic views show the full 1500 mm length
module ht_pipe(od, id, len) {
    rotate([0, 90, 0])  // Z-axis cylinder -> X-axis pipe
    difference() {
        cylinder(h=len, d=od, center=true);
        cylinder(h=len + 2, d=id, center=true); // slightly longer for clean through-hole
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);