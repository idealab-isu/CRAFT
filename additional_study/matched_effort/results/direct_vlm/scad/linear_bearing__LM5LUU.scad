$fn = 128;

bore_d  = 5.0;
outer_d = 10.0;
len     = 28.0;

eps = 0.02;

difference() {
    // Outer body (OD = 10, length = 28), centered for consistent orthographic views
    cylinder(d = outer_d, h = len, center = true);

    // Through bore (ID = 5), extended slightly to guarantee a clean cut
    cylinder(d = bore_d, h = len + 2*eps, center = true);
}