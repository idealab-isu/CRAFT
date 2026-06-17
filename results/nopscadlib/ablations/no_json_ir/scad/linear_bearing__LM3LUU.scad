$fn = 128;

bore_d = 3.0;
od_d   = 7.0;
len_h  = 19.0;

eps = 0.02;

difference() {
    cylinder(h = len_h, d = od_d, center = true);
    cylinder(h = len_h + 2*eps, d = bore_d, center = true);
}