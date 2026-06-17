$fn = 128;

// HT 40 pipe (approx.): DN 40, OD 40 mm, typical wall ~1.8 mm
pipe_length = 1500;     // mm
outer_diameter = 40;    // mm
wall_thickness = 1.8;   // mm

inner_diameter = outer_diameter - 2*wall_thickness;

difference() {
  cylinder(h = pipe_length, d = outer_diameter, center = false);
  translate([0,0,-0.1])
    cylinder(h = pipe_length + 0.2, d = inner_diameter, center = false);
}