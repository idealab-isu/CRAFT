$fn = 128;

inner_d   = 3.5;
outer_d   = 8.0;
thickness = 0.5;

difference() {
    cylinder(h = thickness, d = outer_d, center = true);
    cylinder(h = thickness + 0.2, d = inner_d, center = true);
}