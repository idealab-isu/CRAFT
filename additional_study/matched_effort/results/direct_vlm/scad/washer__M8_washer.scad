$fn = 128;

inner_d = 8.0;
outer_d = 17.0;
thickness = 1.6;

eps = 0.02;

difference() {
    cylinder(h = thickness, d = outer_d, center = true);
    cylinder(h = thickness + 2*eps, d = inner_d, center = true);
}