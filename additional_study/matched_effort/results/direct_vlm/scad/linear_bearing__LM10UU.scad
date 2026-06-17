$fn = 128;

bore_d = 10.0;
od_d   = 19.0;
len    = 29.0;

eps = 0.02;

difference() {
    cylinder(d = od_d, h = len, center = true);
    cylinder(d = bore_d, h = len + 2*eps, center = true);
}