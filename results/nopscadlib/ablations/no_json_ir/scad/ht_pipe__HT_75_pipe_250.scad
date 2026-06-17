// HT 75 pipe 250 mm (single connected solid, hollow, with small end lips)

outer_diameter = 75;      // mm
wall_thickness = 3.2;     // mm
length = 250;             // mm

lip_height = 5;           // mm
lip_extra_d = 5;          // mm (adds to outer diameter)
eps = 0.05;               // small epsilon to avoid coplanar faces

$fn = 120;

module pipe_shell(h, d_out, t) {
    difference() {
        cylinder(h=h, d=d_out, center=false);
        translate([0, 0, -eps])
            cylinder(h=h + 2*eps, d=d_out - 2*t, center=false);
    }
}

module end_lip(h, d_out, extra_d, t) {
    // Ring that is hollow and overlaps the pipe wall (connected via union overlap)
    difference() {
        cylinder(h=h, d=d_out + extra_d, center=false);
        translate([0, 0, -eps])
            cylinder(h=h + 2*eps, d=d_out - 2*t, center=false);
    }
}

module ht_pipe() {
    union() {
        // Main pipe body
        pipe_shell(length, outer_diameter, wall_thickness);

        // Bottom lip: spans [-lip_height, 0] with a tiny overlap into the body
        translate([0, 0, -lip_height])
            end_lip(lip_height + eps, outer_diameter, lip_extra_d, wall_thickness);

        // Top lip: spans [length-eps, length+lip_height] with a tiny overlap into the body
        translate([0, 0, length - eps])
            end_lip(lip_height + eps, outer_diameter, lip_extra_d, wall_thickness);
    }
}

ht_pipe();