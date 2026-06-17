$fn = 128;

id = 6.0;
od = 12.5;
th = 1.5;
eps = 0.02;

difference() {
    cylinder(h = th, d = od, center = true);
    cylinder(h = th + 2*eps, d = id, center = true);
}