$fn = 128;

// PTFE sleeving (tubing) parameters (mm)
length = 60;
outer_d = 6;
inner_d = 4;

// Simple hollow cylinder (tube)
difference() {
  cylinder(h = length, d = outer_d, center = false);
  translate([0, 0, -0.2])
    cylinder(h = length + 0.4, d = inner_d, center = false);
}