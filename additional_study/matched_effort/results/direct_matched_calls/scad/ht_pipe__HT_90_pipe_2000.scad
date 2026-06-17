$fn = 128;

// HT 90 pipe, length 2000 mm (simple hollow cylinder model)
pipe_outer_d = 90;      // mm
wall_thickness = 3.2;   // mm (typical HT pipe wall; adjust if needed)
pipe_length = 2000;     // mm

outer_r = pipe_outer_d/2;
inner_r = outer_r - wall_thickness;

difference() {
    cylinder(h = pipe_length, r = outer_r, center = false);
    translate([0,0,-0.5])
        cylinder(h = pipe_length + 1, r = inner_r, center = false);
}