$fn = 128;

inner_d = 3.0;
outer_d = 10.0;
thickness = 1.5;
eps = 0.02;

difference() {
    cylinder(h = thickness, d = outer_d, center = true);
    cylinder(h = thickness + 2*eps, d = inner_d, center = true);
}