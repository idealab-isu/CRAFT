// HT 40 pipe 2000 mm
// Simplified for fast rendering: single difference(), no extra chamfer solids.

$fn = 48;

// Parameters
pipe_length = 2000;          // mm
outer_diameter = 40;         // mm
wall_thickness = 2;          // mm

socket_length = 60;          // mm
socket_outer_diameter = 46;  // mm
socket_wall_thickness = 2.5; // mm

overlap = 0.5;               // mm (boolean safety)

// Derived
outer_r = outer_diameter/2;
inner_r = max(outer_r - wall_thickness, 0.01);

socket_outer_r = socket_outer_diameter/2;
socket_inner_r = max(socket_outer_r - socket_wall_thickness, 0.01);

// Helpers: cylinders along X (OpenSCAD cylinders are along Z by default)
module cyl_x(h, r=1, center=true) {
    rotate([0, 90, 0]) cylinder(h=h, r=r, center=center);
}

module pipe_fast() {
    difference() {
        // OUTER: main pipe + socket sleeve at +X end
        union() {
            cyl_x(pipe_length, outer_r, center=true);

            // Socket outer sleeve positioned at +X end
            translate([pipe_length/2 - socket_length/2, 0, 0])
                cyl_x(socket_length + overlap, socket_outer_r, center=true);
        }

        // INNER: main bore + socket bore
        union() {
            // Main bore (slightly longer for clean cut)
            cyl_x(pipe_length + 2*overlap, inner_r, center=true);

            // Socket bore (slightly longer for clean cut)
            translate([pipe_length/2 - socket_length/2, 0, 0])
                cyl_x(socket_length + 3*overlap, socket_inner_r, center=true);
        }
    }
}

color("Silver") pipe_fast();