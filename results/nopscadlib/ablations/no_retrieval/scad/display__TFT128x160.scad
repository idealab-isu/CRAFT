$fn = 64;

// =====================
// Parameters (mm)
// =====================
module_L = 46.0;          // overall PCB length (X)
module_W = 34.0;          // overall PCB width  (Y)
module_T = 2.0;           // PCB thickness (Z)

screen_L = 35.0;          // visible/active window size (X)
screen_W = 28.0;          // visible/active window size (Y)
screen_recess = 0.3;      // shallow recess on top surface

bezel_wall = 2.0;         // bezel frame wall thickness around window
bezel_height = 0.8;       // bezel height above PCB

hole_d = 2.6;
hole_edge_margin = 3.0;

header_L = 18.0;
header_W = 5.0;
header_H = 6.0;
header_inset = 1.0;

keepout_L = 30.0;
keepout_W = 20.0;
keepout_H = 3.0;

overlap = 0.8;            // intentional overlap to guarantee connectivity

// =====================
// Helpers
// =====================
module mount_hole(x, y) {
    translate([x, y, 0])
        cylinder(h = module_T + 4*overlap, r = hole_d/2, center = true);
}

module mounting_holes() {
    union() {
        mount_hole( module_L/2 - hole_edge_margin,  module_W/2 - hole_edge_margin);
        mount_hole(-module_L/2 + hole_edge_margin,  module_W/2 - hole_edge_margin);
        mount_hole(-module_L/2 + hole_edge_margin, -module_W/2 + hole_edge_margin);
        mount_hole( module_L/2 - hole_edge_margin, -module_W/2 + hole_edge_margin);
    }
}

// =====================
// Main solids (all connected)
// =====================
module pcb_with_features() {
    difference() {
        // PCB
        cube([module_L, module_W, module_T], center = true);

        // Mounting holes
        mounting_holes();

        // Shallow top recess to suggest LCD active area (NOT a through-cut)
        translate([0, 0, module_T/2 - screen_recess/2])
            cube([screen_L, screen_W, screen_recess + 2*overlap], center = true);
    }
}

module bezel_frame() {
    // Bezel sits on top of PCB and overlaps slightly into it for a single connected solid
    bezel_outer_L = screen_L + 2*bezel_wall;
    bezel_outer_W = screen_W + 2*bezel_wall;

    translate([0, 0, module_T/2 + bezel_height/2 - overlap/2])
    difference() {
        cube([bezel_outer_L, bezel_outer_W, bezel_height], center = true);
        // Window cut through bezel only
        cube([screen_L, screen_W, bezel_height + 4*overlap], center = true);
    }
}

module connector_header() {
    // Header on bottom side, inset from one PCB edge; overlaps into PCB for connectivity
    translate([
        0,
        module_W/2 - header_W/2 - header_inset,
        -module_T/2 - header_H/2 + overlap
    ])
        cube([header_L, header_W, header_H], center = true);
}

module back_components_keepout() {
    // Back-side component block; overlaps into PCB for connectivity
    translate([0, 0, -module_T/2 - keepout_H/2 + overlap])
        cube([keepout_L, keepout_W, keepout_H], center = true);
}

// =====================
// Final connected model
// =====================
union() {
    pcb_with_features();
    bezel_frame();
    connector_header();
    back_components_keepout();
}