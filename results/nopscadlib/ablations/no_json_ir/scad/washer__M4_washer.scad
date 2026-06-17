$fn = 180;

id = 4.0;        // inner diameter (mm)
od = 9.0;        // outer diameter (mm)
th = 0.8;        // thickness (mm)
eps = 0.02;      // small overlap to ensure clean boolean

difference() {
    cylinder(h = th, d = od, center = true);
    cylinder(h = th + 2*eps, d = id, center = true);
}