$fn = 256;

inner_d   = 2.0;
outer_d   = 5.0;
thickness = 0.3;

eps = 0.02;

difference() {
    cylinder(h = thickness, d = outer_d, center = true);
    cylinder(h = thickness + 2*eps, d = inner_d, center = true);
}